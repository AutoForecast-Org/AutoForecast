# Configurazione Supabase Auth

L'app accetta esclusivamente Sign in with Apple: non esistono UI né chiamate API per Google, Facebook, email o password.

## 1. Provider di autenticazione

In **Authentication → Providers**, abilitare solo Apple. Disabilitare Google, Facebook ed Email per impedire anche lato server registrazioni/accessi con questi metodi.

L'app usa il flusso nativo `ASAuthorizationController` e invia l'identity token a Supabase con `signInWithIdToken`. Il bundle identifier iOS è `com.auto.forecast.AutoForecast`; la capability **Sign in with Apple** è inclusa nell'entitlement del target.

## 2. Cancellazione account

La UI invoca la Edge Function `delete-account`; essa identifica l'utente dal JWT e usa la service-role esclusivamente sul server.

Installare Supabase CLI, autenticarsi e poi eseguire:

```bash
supabase link --project-ref mxfghxnyhrxsorxjztpz
supabase functions deploy delete-account
```

Non impostare mai `SUPABASE_SERVICE_ROLE_KEY` nell'app iOS: le Edge Functions Supabase ricevono `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY` come segreti di runtime.

Tutte le tabelle che contengono dati personali devono avere una FK `user_id → auth.users(id) ON DELETE CASCADE`; aggiungere nella funzione la rimozione esplicita di dati non relazionali, ad esempio file in Storage. Verificare in staging che una chiamata a `delete-account` rimuova l'utente e tutti i suoi dati prima della pubblicazione.

## 3. Sicurezza dati

Abilitare RLS su ogni tabella con dati per utente e creare policy che limitino lettura/scrittura a `auth.uid() = user_id`. L'anon key nell'app è progettata per essere pubblica; le policy RLS, non la segretezza della chiave, proteggono i dati.
