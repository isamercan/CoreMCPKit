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
            "model": "gpt-3.5-turbo",
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
        let fullPrompt = """
        System: \(systemPrompt)
        User: \(userPrompt)
        """

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }
}
