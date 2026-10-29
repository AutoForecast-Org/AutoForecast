import Foundation
import Supabase

@MainActor
enum SupabaseForecastClient {
    static func generateForecast(_ input: AIForecastInput) async throws -> AIForecastOutput {
        let client = SupabaseClientProvider.client
        let accessToken: String
        do {
            accessToken = try await client.auth.session.accessToken
        } catch {
            throw AIForecastError.authenticationRequired
        }
        // Encode explicitly: an encoding failure must not become an empty request body.
        let body = try JSONEncoder().encode(input)
        do {
            let data: Data = try await client.functions.invoke(
                "generate-forecast",
                options: .init(headers: [
                    "Authorization": "Bearer \(accessToken)",
                    "Content-Type": "application/json"
                ], body: body),
                decode: { data, _ in data }
            )
            do {
                return try JSONDecoder().decode(AIForecastOutput.self, from: data)
            } catch {
                throw AIForecastError.invalidResponse("Formato della risposta server non riconosciuto.")
            }
        } catch let error as FunctionsError {
            switch error {
            case .httpError(let code, let data):
                throw ForecastBackendError.map(statusCode: code, data: data)
            case .relayError:
                throw AIForecastError.requestFailed("Impossibile raggiungere il servizio di previsione.")
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw AIForecastError.requestFailed("Nessuna connessione a Internet.")
            case .timedOut:
                throw AIForecastError.requestFailed("La previsione ha impiegato troppo tempo. Riprova più tardi.")
            default:
                throw AIForecastError.requestFailed("Connessione al servizio di previsione interrotta.")
            }
        }
        // No automatic POST retry: a lost response may already have incurred inference cost.
    }
}
