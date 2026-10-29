# Backend AutoForecast

L'app usa Supabase Auth con Sign in with Apple e due Edge Functions:

- `generate-forecast`: verifica l'utente, applica le quote e chiama OpenAI.
- `delete-account`: elimina l'account autenticato; richiede cancellazione a cascata
  dei dati personali tramite FK verso `auth.users`.

Mantenere abilitato solo il provider Apple. Le tabelle con dati personali richiedono
RLS e policy per `auth.uid() = user_id`. La chiave pubblica Supabase può essere
nell'app; chiavi OpenAI e service-role devono restare esclusivamente sul server.

## Configurazione e deploy

I segreti si gestiscono nella dashboard Supabase, Edge Functions → Secrets:

| Nome | Valore iniziale |
| --- | --- |
| `OPENAI_API_KEY` | Chiave privata OpenAI |
| `OPENAI_MODEL` | `gpt-4o-mini` |
| `FORECAST_REQUESTS_PER_MINUTE` | `3` |
| `FORECAST_REQUESTS_PER_DAY` | `20` |
| `FORECAST_GLOBAL_REQUESTS_PER_DAY` | `500` |

Supabase fornisce `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY`
al runtime hosted. Non aggiungerle alla configurazione iOS.

```bash
supabase login
supabase link --project-ref mxfghxnyhrxsorxjztpz
supabase functions deploy generate-forecast
# Solo se viene modificata anche la cancellazione account:
supabase functions deploy delete-account
```

Il prompt, lo schema JSON e il modello delle previsioni sono gestiti sul server.
Una loro modifica richiede il deploy di `generate-forecast`.
Mantenere `verify_jwt = true`; la funzione verifica anche l'identità tramite Auth.
Le migrazioni SQL in `migrations/` vanno conservate e applicate agli altri ambienti
prima del deploy.

Le quote contano i tentativi ammessi, anche se OpenAI fallisce. Il giorno è UTC,
il minuto è una finestra fissa. Non sono limiti di spesa monetari. La funzione
accetta al massimo 16 KiB di input, 50 anni di analisi e 4096 token di output.
Il modello supportato è `gpt-4o-mini`, anche nello snapshot `2024-07-18`.

## Verifiche

```bash
bash Tests/Forecast/run.sh
node --test Tests/Forecast/server.test.ts
bash Tests/Forecast/test-quota.sh
```

I test Swift richiedono Xcode; quelli server richiedono Node.js con supporto TypeScript
(verificati con Node 25). Il test SQL richiede PostgreSQL 17: usa un cluster locale
temporaneo, senza collegarsi al progetto remoto. Per un'installazione diversa
specificare `PG_BIN=/percorso/bin`.

La funzione restituisce `401` per sessione non valida, `429` per quote esaurite,
`422` per output non valido e `503` per configurazione/provider/database indisponibili.
Non esporre o registrare chiavi, JWT o corpi degli errori upstream.
