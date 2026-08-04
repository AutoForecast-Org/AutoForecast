// Deletes the caller's Supabase Auth user. Keep SUPABASE_SERVICE_ROLE_KEY only in Edge Function secrets.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const authorization = request.headers.get("Authorization");
  const accessToken = authorization?.replace(/^Bearer\s+/i, "");
  if (!accessToken) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const projectURL = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const callerClient = createClient(projectURL, anonKey);
  const { data: { user }, error: userError } = await callerClient.auth.getUser(accessToken);

  if (userError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // Add explicit cleanup here for data not protected by ON DELETE CASCADE (for example Storage objects).
  // Tables with a user_id foreign key should reference auth.users(id) ON DELETE CASCADE.
  const adminClient = createClient(projectURL, serviceRoleKey);
  // const { error: deleteError } = await adminClient.auth.admin.deleteUser(user.id, true);
  const { error: deleteError } = await adminClient.auth.admin.deleteUser(user.id);

  if (deleteError) {
    console.error("Unable to delete account", deleteError);
    return new Response(JSON.stringify({ error: "Unable to delete account" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  return new Response(null, { status: 204, headers: corsHeaders });
});
