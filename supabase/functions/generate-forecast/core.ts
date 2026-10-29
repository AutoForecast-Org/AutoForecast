export class ForecastError extends Error {
  status: number;
  code: string;
  constructor(status: number, code: string, message: string) {
    super(message); this.status = status; this.code = code;
  }
}

function object(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new ForecastError(400, "invalid_input", "Expected object");
  }
  return value as Record<string, unknown>;
}
function text(value: unknown, name: string, optional = false): string | undefined {
  if (optional && (value === undefined || value === null || value === "")) return undefined;
  if (typeof value !== "string" || value.trim().length === 0 || value.length > 160 || /[\u0000-\u001f]/.test(value)) {
    throw new ForecastError(400, "invalid_input", `Invalid ${name}`);
  }
  return value.trim();
}
function number(value: unknown, name: string, min: number, max: number, integer = true): number {
  if (typeof value !== "number" || !Number.isFinite(value) || value < min || value > max || (integer && !Number.isInteger(value))) {
    throw new ForecastError(400, "invalid_input", `Invalid ${name}`);
  }
  return value;
}

// Rebuild an allowlisted payload. Client-provided instructions, schemas, model,
// missingParameters, evidence, dates and currency are never forwarded to OpenAI.
export function normalizeInput(raw: unknown, now = new Date()) {
  const input = object(raw);
  const source = object(input.vehicle);
  const date = new Intl.DateTimeFormat("en-CA", { timeZone: "Europe/Rome", year: "numeric", month: "2-digit", day: "2-digit" }).formatToParts(now);
  const part = (name: string) => date.find((p) => p.type === name)!.value;
  const valuationDate = `${part("year")}-${part("month")}-${part("day")}`;
  const valuationYear = Number(part("year"));
  const optionalString = (name: string) => text(source[name], name, true);
  const vehicle = {
    brand: text(source.brand, "brand")!, model: text(source.model, "model")!,
    engine: text(source.engine, "engine")!,
    registrationYear: number(source.registrationYear, "registrationYear", 1886, valuationYear),
    currentMileageKm: number(source.currentMileageKm, "currentMileageKm", 0, 5_000_000),
    version: optionalString("version"), color: optionalString("color"), zone: optionalString("zone"),
    certifiedMaintenance: optionalString("certifiedMaintenance"),
    numberOfOwners: source.numberOfOwners == null ? undefined : number(source.numberOfOwners, "numberOfOwners", 1, 100),
    optionals: undefined as string[] | undefined,
  };
  if (source.optionals != null) {
    if (!Array.isArray(source.optionals) || source.optionals.length > 40) throw new ForecastError(400, "invalid_input", "Invalid optionals");
    const options = [...new Set(source.optionals.map((item) => text(item, "optional")!))];
    vehicle.optionals = options.length ? options : undefined;
  }
  const analysisYears = number(input.analysisYears, "analysisYears", 1, 50);
  const referencePurchasePrice = number(input.referencePurchasePrice, "referencePurchasePrice", 1, 100_000_000, false);
  const age = valuationYear - vehicle.registrationYear;
  // Preserve the app's mileage assumption, but validate it and assign its provenance server-side.
  const annualMileageKm = age > 0 ? Math.floor(vehicle.currentMileageKm / age)
    : number(input.annualMileageKm, "annualMileageKm", 0, 500_000);
  const missingParameters = ["version", "color", "zone", "certifiedMaintenance", "numberOfOwners", "optionals"]
    .filter((name) => vehicle[name as keyof typeof vehicle] === undefined);
  return {
    schemaVersion: "2", promptVersion: "2", vehicle, referencePurchasePrice,
    referencePriceSource: "client_supplied_application_reference_not_verified_market_quote",
    valuationDate, valuationYear, analysisYears, startYear: vehicle.registrationYear,
    currencyCode: "EUR", monetaryBasis: "constant_reference_euros_no_inflation_projection",
    annualMileageKm, annualMileageSource: age > 0 ? "inferred_from_current_odometer_and_vehicle_age" : "client_supplied_fuel_dataset_or_technical_default",
    missingParameters, marketEvidence: [],
  };
}
export type ForecastInput = ReturnType<typeof normalizeInput>;

export function responseFormat(count: number) {
  return {
    type: "json_schema",
    json_schema: {
      name: "vehicle_forecast_v2", strict: true,
      schema: {
        type: "object", additionalProperties: false, required: ["data"],
        properties: { data: {
          type: "array", minItems: count, maxItems: count,
          items: {
            type: "object", additionalProperties: false, required: ["year", "value"],
            properties: { year: { type: "integer" }, value: { type: "number", minimum: 0 } },
          },
        } },
      },
    },
  };
}

export function parseOutput(envelope: unknown, input: ForecastInput) {
  const invalid = () => new ForecastError(422, "invalid_forecast", "No valid forecast");
  try {
    const result = object(envelope);
    if (!Array.isArray(result.choices) || result.choices.length !== 1) throw invalid();
    const choice = object(result.choices[0]);
    const message = object(choice.message);
    if (choice.finish_reason !== "stop" || message.refusal != null || typeof message.content !== "string") throw invalid();
    const output = object(JSON.parse(message.content));
    if (Object.keys(output).length !== 1 || !Array.isArray(output.data) || output.data.length !== input.analysisYears + 1) throw invalid();
    const data = output.data.map((value, index) => {
      const point = object(value);
      if (Object.keys(point).sort().join(",") !== "value,year" || point.year !== input.startYear + index ||
        typeof point.value !== "number" || !Number.isFinite(point.value) || point.value < 0) throw invalid();
      return { year: point.year as number, value: point.value };
    });
    return { data };
  } catch { throw invalid(); }
}
