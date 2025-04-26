//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public final class OpenAIProvider: LLMProvider {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func complete(prompt: String, contexts: [[String: Any]]) async throws -> String {
        let contextString = try JSONSerialization.data(withJSONObject: contexts, options: .prettyPrinted)
        let contextJSON = String(data: contextString, encoding: .utf8) ?? ""

        let fullPrompt = "User Prompt: \(prompt)\n\nContexts:\n\(contextJSON)"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful AI agent."],
                ["role": "user", "content": fullPrompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "No response."
    }
}

public extension OpenAIProvider {
    func send(systemPrompt: String, userPrompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        // HTTP Hata Kontrolü
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OpenAI HTTP Error \(httpResponse.statusCode): \(errorMessage)")
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let rawJson = try? JSONSerialization.jsonObject(with: data, options: [])
        print("📊 OpenAI Raw Response: \(String(describing: rawJson))")

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.emptyResponse
        }

        return content
    }

}



enum OpenAIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "OpenAI: Invalid response received."
        case .httpError(let statusCode, let message):
            return "OpenAI HTTP Error \(statusCode): \(message)"
        case .emptyResponse:
            return "OpenAI returned an empty response."
        }
    }
}
