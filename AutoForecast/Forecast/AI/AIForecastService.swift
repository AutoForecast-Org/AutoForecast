//
//  AIForecastService.swift
//
//  Copyright (c) 2025 AutoForecast.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - Configuration

struct AIServiceConfiguration {
    let apiKey: String
    let model: String

    static let current = AIServiceConfiguration(
        apiKey: Bundle.main.aiString(for: "OpenAIAPIKey") ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
        model: Bundle.main.aiString(for: "OpenAIModel") ?? "gpt-4o-mini"
    )
}

private extension Bundle {
    func aiString(for key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // Unresolved build-setting placeholders (e.g. "$(OPENAI_API_KEY)") are treated as missing.
        return trimmed.isEmpty || trimmed.hasPrefix("$(") ? nil : trimmed
    }
}

// MARK: - Structured Input / Output

struct AIForecastInput: Codable {
    let userCar: UserCar
    let referencePurchasePrice: Double
    let analysisYears: Int
    let startYear: Int
    let currencyCode: String
}

struct AIForecastOutput: Codable {
    let purchasePrice: Double
    let data: [DepreciationPoint]
    let optimisticData: [DepreciationPoint]
    let pessimisticData: [DepreciationPoint]
}

// MARK: - Errors

enum AIForecastError: LocalizedError {
    case missingAPIKey
    case serviceUnavailable(statusCode: Int, details: String?)
    case invalidResponse(String)
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Imposta la OpenAI API key in Info.plist (OpenAIAPIKey) oppure nella variabile OPENAI_API_KEY."
        case .serviceUnavailable(let statusCode, let details):
            let baseMessage = "OpenAI è temporaneamente sovraccarico (HTTP \(statusCode)). Riprova tra poco."
            guard let details, !details.isEmpty else { return baseMessage }
            return "\(baseMessage) Dettagli: \(details)"
        case .invalidResponse(let message):
            return "La risposta dell'AI non è valida: \(message)"
        case .requestFailed(let message):
            return message
        }
    }
}

// MARK: - Service

@MainActor
final class AIForecastService {
    private let client: OpenAIForecastClient

    init(configuration: AIServiceConfiguration = .current) {
        self.client = OpenAIForecastClient(
            apiKey: configuration.apiKey,
            model: configuration.model
        )
    }

    func generateForecast(for userCar: UserCar, searchManager: SearchManager, years: Int = 20) async throws -> UserCarForecast {
        let purchasePrice = DepreciationEngine(searchManager: searchManager).resolvePurchasePrice(userCar: userCar)
        let startYear = userCar.registrationYear
        let input = AIForecastInput(
            userCar: userCar,
            referencePurchasePrice: purchasePrice,
            analysisYears: years,
            startYear: startYear,
            currencyCode: "EUR"
        )

        let output = try await client.generateForecast(input: input)

        let normalizedBaseSeries = try normalizeSeries(
            output.data,
            startYear: startYear,
            years: years,
            label: "data"
        )
        let normalizedOptimisticSeries = try normalizeSeries(
            output.optimisticData,
            startYear: startYear,
            years: years,
            label: "optimisticData"
        )
        let normalizedPessimisticSeries = try normalizeSeries(
            output.pessimisticData,
            startYear: startYear,
            years: years,
            label: "pessimisticData"
        )

        let normalizedPurchasePrice = output.purchasePrice > 0 ? output.purchasePrice : purchasePrice

        return UserCarForecast(
            userCar: userCar,
            data: normalizedBaseSeries,
            optimisticData: normalizedOptimisticSeries,
            pessimisticData: normalizedPessimisticSeries,
            purchasePrice: normalizedPurchasePrice,
            isExmample: false,
            isSaved: false
        )
    }

    private func normalizeSeries(
        _ points: [DepreciationPoint],
        startYear: Int,
        years: Int,
        label: String
    ) throws -> [DepreciationPoint] {
        let expectedYears = Array(startYear...startYear + years)
        let lookup = Dictionary(grouping: points, by: \.year)
            .compactMapValues { $0.sorted(by: { $0.year < $1.year }).first?.value }

        var normalizedPoints: [DepreciationPoint] = []
        normalizedPoints.reserveCapacity(expectedYears.count)

        for year in expectedYears {
            guard let value = lookup[year] else {
                throw AIForecastError.invalidResponse("Serie \(label) incompleta: manca l'anno \(year).")
            }
            normalizedPoints.append(DepreciationPoint(year: year, value: value))
        }

        return normalizedPoints
    }
}

// MARK: - OpenAI client
private struct OpenAIForecastClient {
    let apiKey: String
    let model: String
    private let session: URLSession

    init(apiKey: String, model: String, session: URLSession = .forecasting) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func generateForecast(input: AIForecastInput) async throws -> AIForecastOutput {
        guard !apiKey.isEmpty else { throw AIForecastError.missingAPIKey }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIForecastError.requestFailed("URL OpenAI non valida.")
        }

        let body = OpenAIChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: ForecastPromptBuilder.systemPrompt),
                .init(role: "user", content: ForecastPromptBuilder.makePrompt(for: input))
            ],
            temperature: 0.2,
            responseFormat: .jsonObject
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await performRetriableRequest(request, session: session)
        try validateHTTPResponse(response, data: data)

        let apiResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
        guard let text = apiResponse.choices.first?.message.content, !text.isEmpty else {
            throw AIForecastError.invalidResponse("OpenAI non ha restituito contenuto JSON.")
        }

        return try decodeAIForecastOutput(from: text)
    }
}

private struct OpenAIChatRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    enum ResponseFormat: String, Encodable {
        case jsonObject = "json_object"

        // The API expects {"type": "json_object"}, not a bare string.
        private enum CodingKeys: String, CodingKey { case type }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(rawValue, forKey: .type)
        }
    }

    let model: String
    let messages: [Message]
    let temperature: Double
    let responseFormat: ResponseFormat

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case responseFormat = "response_format"
    }
}

private struct OpenAIChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String?
        }

        let message: Message
    }

    let choices: [Choice]
}

// MARK: - Prompt Builder

private enum ForecastPromptBuilder {
    static let systemPrompt = """
    Sei un analista esperto di svalutazione auto.
    Devi rispondere SOLO con JSON valido, senza markdown, senza spiegazioni e senza testo extra.
    Il JSON deve rispettare esattamente la struttura richiesta.
    """

    static func makePrompt(for input: AIForecastInput) -> String {
        let requestJSON: String
        if let encoded = try? JSONEncoder().encode(input), let string = String(data: encoded, encoding: .utf8) {
            requestJSON = string
        } else {
            requestJSON = "{}"
        }

        return """
        Genera una previsione della svalutazione del veicolo usando esclusivamente i dati forniti.

        Regole:
        - restituisci ESATTAMENTE \(input.analysisYears + 1) punti per ogni serie, da startYear a startYear + analysisYears incluso
        - i punti devono essere ordinati per anno crescente
        - `purchasePrice` deve essere un numero positivo in EUR
        - `data` è la serie base
        - `optimisticData` deve essere uguale o superiore alla serie base
        - `pessimisticData` deve essere uguale o inferiore alla serie base
        - non aggiungere campi extra
        - non usare markdown

        Schema JSON di output:
        {
          "purchasePrice": 0,
          "data": [{"year": 2025, "value": 0}],
          "optimisticData": [{"year": 2025, "value": 0}],
          "pessimisticData": [{"year": 2025, "value": 0}]
        }

        Input JSON:
        \(requestJSON)
        """
    }
}

// MARK: - Shared helpers

private func validateHTTPResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AIForecastError.requestFailed("Risposta OpenAI non valida.")
    }

    guard (200...299).contains(httpResponse.statusCode) else {
        let details = httpErrorDetails(from: data)
        if isTransientStatus(httpResponse.statusCode) {
            throw AIForecastError.serviceUnavailable(statusCode: httpResponse.statusCode, details: details.isEmpty ? nil : details)
        }

        if details.isEmpty {
            throw AIForecastError.requestFailed("OpenAI ha restituito HTTP \(httpResponse.statusCode).")
        } else {
            throw AIForecastError.requestFailed("OpenAI ha restituito HTTP \(httpResponse.statusCode): \(details)")
        }
    }
}

private func mapForecastNetworkError(_ error: Error) -> Error {
    guard let urlError = error as? URLError else { return error }

    switch urlError.code {
    case .timedOut:
        return AIForecastError.requestFailed("OpenAI ha impiegato troppo tempo a rispondere. Riprova tra poco.")
    case .notConnectedToInternet:
        return AIForecastError.requestFailed("Nessuna connessione a Internet.")
    case .networkConnectionLost:
        return AIForecastError.requestFailed("Connessione di rete persa durante la richiesta a OpenAI.")
    case .cannotFindHost, .cannotConnectToHost:
        return AIForecastError.requestFailed("Impossibile raggiungere OpenAI.")
    default:
        return error
    }
}

private func performRetriableRequest(
    _ request: URLRequest,
    session: URLSession = .forecasting,
    maxAttempts: Int = 3
) async throws -> (Data, URLResponse) {
    precondition(maxAttempts >= 1)

    var lastError: Error?

    for attempt in 1...maxAttempts {
        do {
            let result = try await session.data(for: request)
            if shouldRetryHTTPStatus(result.1, attempt: attempt, maxAttempts: maxAttempts) {
                try await Task.sleep(nanoseconds: retryDelayNanoseconds(for: result.1, attempt: attempt))
                continue
            }
            return result
        } catch {
            lastError = mapForecastNetworkError(error)
            if attempt < maxAttempts, shouldRetryNetworkError(error) {
                try await Task.sleep(nanoseconds: retryDelayNanoseconds(for: nil, attempt: attempt))
                continue
            }
            throw lastError ?? error
        }
    }

    if let lastError {
        throw lastError
    }

    throw AIForecastError.requestFailed("OpenAI non ha restituito una risposta valida.")
}

private func shouldRetryHTTPStatus(_ response: URLResponse, attempt: Int, maxAttempts: Int) -> Bool {
    guard attempt < maxAttempts, let httpResponse = response as? HTTPURLResponse else { return false }
    return isTransientStatus(httpResponse.statusCode)
}

private func shouldRetryNetworkError(_ error: Error) -> Bool {
    guard let urlError = error as? URLError else { return false }
    return [
        .timedOut,
        .networkConnectionLost,
        .cannotFindHost,
        .cannotConnectToHost,
        .dnsLookupFailed,
        .internationalRoamingOff,
        .callIsActive,
        .dataNotAllowed
    ].contains(urlError.code)
}

private func isTransientStatus(_ statusCode: Int) -> Bool {
    [429, 500, 502, 503, 504].contains(statusCode)
}

private func retryDelayNanoseconds(for response: URLResponse?, attempt: Int) -> UInt64 {
    if let httpResponse = response as? HTTPURLResponse,
       let retryAfterHeader = httpResponse.value(forHTTPHeaderField: "Retry-After"),
       let retryAfterSeconds = TimeInterval(retryAfterHeader.trimmingCharacters(in: .whitespacesAndNewlines)),
       retryAfterSeconds > 0 {
        return UInt64(min(retryAfterSeconds, 30) * 1_000_000_000)
    }

    let seconds = min(pow(2.0, Double(attempt - 1)), 8.0)
    let jitter = Double.random(in: 0.15...0.45)
    return UInt64((seconds + jitter) * 1_000_000_000)
}

private func httpErrorDetails(from data: Data) -> String {
    guard let string = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
          !string.isEmpty else { return "" }

    if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let error = object["error"] as? [String: Any] {
        let message = (error["message"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = (error["code"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let combined = [code, message].compactMap { $0 }.joined(separator: ": ")
        if !combined.isEmpty { return combined }
    }
    return string
}

private extension URLSession {
    static let forecasting: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 180
        return URLSession(configuration: configuration)
    }()
}

private func decodeAIForecastOutput(from rawText: String) throws -> AIForecastOutput {
    let jsonText = rawText
        .replacingOccurrences(of: "```json", with: "")
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    guard let data = jsonText.data(using: .utf8) else {
        throw AIForecastError.invalidResponse("Impossibile convertire la risposta in UTF-8.")
    }

    do {
        return try JSONDecoder().decode(AIForecastOutput.self, from: data)
    } catch {
        throw AIForecastError.invalidResponse(error.localizedDescription)
    }
}
