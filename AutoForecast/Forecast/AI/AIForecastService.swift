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

// MARK: - Provider

enum AIProvider: String {
    case gemini
    case openAI
}

// MARK: - Configuration

struct AIServiceConfiguration {
    let provider: AIProvider
    let geminiAPIKey: String
    let geminiModel: String
    let openAIAPIKey: String
    let openAIModel: String

    static let current = AIServiceConfiguration(
        provider: Bundle.main.aiProvider,
        geminiAPIKey: Bundle.main.aiString(for: "GeminiAPIKey") ?? ProcessInfo.processInfo.environment[" "] ?? "",
        geminiModel: Bundle.main.aiString(for: "GeminiModel") ?? "gemini-2.0-flash",
        openAIAPIKey: Bundle.main.aiString(for: "OpenAIAPIKey") ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
        openAIModel: Bundle.main.aiString(for: "OpenAIModel") ?? "gpt-4o-mini"
    )
}

private extension Bundle {
    var aiProvider: AIProvider {
        let rawValue = (object(forInfoDictionaryKey: "AIProvider") as? String)?.lowercased() ?? AIProvider.gemini.rawValue
        return AIProvider(rawValue: rawValue) ?? .gemini
    }

    func aiString(for key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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
    case missingAPIKey(provider: AIProvider)
    case invalidResponse(String)
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey(let provider):
            switch provider {
            case .gemini:
                return "Imposta la Gemini API key in Info.plist (GeminiAPIKey) oppure nella variabile GEMINI_API_KEY."
            case .openAI:
                return "Imposta la OpenAI API key in Info.plist (OpenAIAPIKey) oppure nella variabile OPENAI_API_KEY."
            }
        case .invalidResponse(let message):
            return "La risposta dell'AI non è valida: \(message)"
        case .requestFailed(let message):
            return message
        }
    }
}

// MARK: - Provider contract

protocol AIForecastProviding {
    func generateForecast(input: AIForecastInput) async throws -> AIForecastOutput
}

// MARK: - Service

@MainActor
final class AIForecastService {
    private let configuration: AIServiceConfiguration
    private let provider: any AIForecastProviding

    init(configuration: AIServiceConfiguration = .current) {
        self.configuration = configuration

        switch configuration.provider {
        case .gemini:
            provider = GeminiAIForecastProvider(
                apiKey: configuration.geminiAPIKey,
                model: configuration.geminiModel
            )
        case .openAI:
            provider = OpenAIForecastProvider(
                apiKey: configuration.openAIAPIKey,
                model: configuration.openAIModel
            )
        }
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

        let output = try await provider.generateForecast(input: input)

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

// MARK: - Gemini
private struct GeminiAIForecastProvider: AIForecastProviding {
    let apiKey: String
    let model: String
    private let session: URLSession

    init(apiKey: String, model: String, session: URLSession = .forecasting) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func generateForecast(input: AIForecastInput) async throws -> AIForecastOutput {
        guard !apiKey.isEmpty else { throw AIForecastError.missingAPIKey(provider: .gemini) }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw AIForecastError.requestFailed("URL Gemini non valida.")
        }

        let prompt = ForecastPromptBuilder.makePrompt(for: input)
        let body = GeminiRequest(
            contents: [
                .init(role: "user", parts: [.init(text: prompt)])
            ],
            generationConfig: .init(
                temperature: 0.2,
                responseMimeType: "application/json"
            )
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw mapForecastNetworkError(error, providerName: "Gemini")
        }
        try validateHTTPResponse(response, providerName: "Gemini")

        let apiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = apiResponse.candidates?.first?.content.parts.compactMap({ $0.text }).joined(), !text.isEmpty else {
            throw AIForecastError.invalidResponse("Gemini non ha restituito contenuto JSON.")
        }

        return try decodeAIForecastOutput(from: text)
    }
}

private struct GeminiRequest: Encodable {
    struct Content: Encodable {
        struct Part: Encodable {
            let text: String
        }

        let role: String
        let parts: [Part]
    }

    struct GenerationConfig: Encodable {
        let temperature: Double
        let responseMimeType: String
    }

    let contents: [Content]
    let generationConfig: GenerationConfig
}

private struct GeminiResponse: Decodable {
    struct Candidate: Decodable {
        struct Content: Decodable {
            struct Part: Decodable {
                let text: String?
            }

            let parts: [Part]
        }

        let content: Content
    }

    let candidates: [Candidate]?
}

// MARK: - OpenAI

private struct OpenAIForecastProvider: AIForecastProviding {
    let apiKey: String
    let model: String
    private let session: URLSession

    init(apiKey: String, model: String, session: URLSession = .forecasting) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func generateForecast(input: AIForecastInput) async throws -> AIForecastOutput {
        guard !apiKey.isEmpty else { throw AIForecastError.missingAPIKey(provider: .openAI) }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        let prompt = ForecastPromptBuilder.makePrompt(for: input)
        let body = OpenAIChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: ForecastPromptBuilder.systemPrompt),
                .init(role: "user", content: prompt)
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

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw mapForecastNetworkError(error, providerName: "OpenAI")
        }
        try validateHTTPResponse(response, providerName: "OpenAI")

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
        - restituisci ESATTAMENTE 21 punti per ogni serie, da startYear a startYear + analysisYears incluso
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

private func validateHTTPResponse(_ response: URLResponse, providerName: String) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AIForecastError.requestFailed("Risposta \(providerName) non valida.")
    }

    guard (200...299).contains(httpResponse.statusCode) else {
        throw AIForecastError.requestFailed("\(providerName) ha restituito HTTP \(httpResponse.statusCode).")
    }
}

private func mapForecastNetworkError(_ error: Error, providerName: String) -> Error {
    guard let urlError = error as? URLError else { return error }

    switch urlError.code {
    case .timedOut:
        return AIForecastError.requestFailed("\(providerName) ha impiegato troppo tempo a rispondere. Riprova tra poco.")
    case .notConnectedToInternet:
        return AIForecastError.requestFailed("Nessuna connessione a Internet.")
    case .networkConnectionLost:
        return AIForecastError.requestFailed("Connessione di rete persa durante la richiesta a \(providerName).")
    case .cannotFindHost, .cannotConnectToHost:
        return AIForecastError.requestFailed("Impossibile raggiungere \(providerName).")
    default:
        return error
    }
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
    let cleanedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
    let jsonText = cleanedText
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
