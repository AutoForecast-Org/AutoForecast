import { ForecastError, normalizeInput, parseOutput, responseFormat } from "./core.ts";
import { systemPrompt } from "./prompt.ts";

type Dependencies = {
  env: (name: string) => string | undefined;
  fetch: typeof fetch;
  now?: () => Date;
};
const json = (body: unknown, status = 200, headers: Record<string, string> = {}) => new Response(JSON.stringify(body), {
  status, headers: { "Content-Type": "application/json", "Cache-Control": "no-store", ...headers },
});
const MAX_BODY_BYTES = 16_384;
async function boundedJSON(request: Request) {
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("application/json")) throw new ForecastError(400, "invalid_input", "JSON required");
  if (Number(request.headers.get("content-length")) > MAX_BODY_BYTES) throw new ForecastError(413, "invalid_input", "Body too large");
  if (!request.body) throw new ForecastError(400, "invalid_input", "Missing body");
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let length = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      length += value.byteLength;
      if (length > MAX_BODY_BYTES) { await reader.cancel(); throw new ForecastError(413, "invalid_input", "Body too large"); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(length);
  let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.byteLength; }
  try { return JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes)); }
  catch { throw new ForecastError(400, "invalid_input", "Invalid JSON"); }
}

export function createHandler(deps: Dependencies) {
  return async (request: Request): Promise<Response> => {
    if (request.method !== "POST") return json({ code: "method_not_allowed" }, 405, { Allow: "POST" });
    try {
      const authorization = request.headers.get("authorization");
      if (!authorization || !/^Bearer\s+\S+$/i.test(authorization)) throw new ForecastError(401, "unauthorized", "Sign in required");
      const url = deps.env("SUPABASE_URL");
      const anonKey = deps.env("SUPABASE_ANON_KEY");
      const serviceKey = deps.env("SUPABASE_SERVICE_ROLE_KEY");
      const apiKey = deps.env("OPENAI_API_KEY");
      const model = deps.env("OPENAI_MODEL") || "gpt-4o-mini";
      if (!url || !anonKey || !serviceKey || !apiKey || !["gpt-4o-mini", "gpt-4o-mini-2024-07-18"].includes(model)) {
        throw new ForecastError(503, "service_unavailable", "Server configuration required");
      }
      const signal = AbortSignal.timeout(100_000);
      // Verify the actual user with Auth; an anon/project key alone must never authorize spending.
      const auth = await deps.fetch(`${url}/auth/v1/user`, { headers: { apikey: anonKey, Authorization: authorization }, signal });
      if (!auth.ok) {
        if (auth.status >= 500) throw new ForecastError(503, "service_unavailable", "Auth unavailable");
        throw new ForecastError(401, "unauthorized", "Invalid session");
      }
      const user = await auth.json();
      if (typeof user.id !== "string" || !/^[0-9a-f-]{36}$/i.test(user.id) || user.is_anonymous === true) throw new ForecastError(401, "unauthorized", "Invalid user");
      const input = normalizeInput(await boundedJSON(request), deps.now?.() ?? new Date());
      const limit = (name: string, fallback: number, max: number) => {
        const value = Number(deps.env(name) ?? fallback);
        if (!Number.isInteger(value) || value < 1 || value > max) throw new ForecastError(503, "service_unavailable", "Invalid limits");
        return value;
      };
      // Atomic persistent admission control. Failure to read/update quotas fails closed.
      const quotaResponse = await deps.fetch(`${url}/rest/v1/rpc/consume_forecast_quota`, {
        method: "POST", headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, "Content-Type": "application/json" },
        body: JSON.stringify({ p_user_id: user.id,
          p_minute_limit: limit("FORECAST_REQUESTS_PER_MINUTE", 3, 100),
          p_daily_limit: limit("FORECAST_REQUESTS_PER_DAY", 20, 10_000),
          p_global_daily_limit: limit("FORECAST_GLOBAL_REQUESTS_PER_DAY", 500, 100_000) }), signal,
      });
      if (!quotaResponse.ok) throw new ForecastError(503, "service_unavailable", "Quota storage unavailable");
      const quota = await quotaResponse.json();
      if (quota.allowed === false) {
        const retryAfter = Number.isInteger(quota.retry_after_seconds) ? Math.max(1, Math.min(quota.retry_after_seconds, 86400)) : 60;
        return json({ code: "quota_exceeded", retryAfterSeconds: retryAfter }, 429, { "Retry-After": String(retryAfter) });
      }
      if (quota.allowed !== true) throw new ForecastError(503, "service_unavailable", "Invalid quota response");
      const response = await deps.fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST", headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" }, signal,
        body: JSON.stringify({ model, temperature: 0.2, max_completion_tokens: 4096,
          messages: [{ role: "system", content: systemPrompt }, { role: "user", content: JSON.stringify(input) }],
          response_format: responseFormat(input.analysisYears + 1) }),
      });
      if (!response.ok) throw new ForecastError(503, "service_unavailable", "Provider unavailable");
      return json(parseOutput(await response.json(), input));
    } catch (error) {
      // Never forward or log upstream bodies, session tokens, prompts or credentials.
      if (error instanceof ForecastError) return json({ code: error.code }, error.status);
      return json({ code: "service_unavailable" }, 503);
    }
  };
}
