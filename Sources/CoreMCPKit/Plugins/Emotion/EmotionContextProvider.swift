//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
public final class EmotionContextProvider: MCPContextProvider {
    private let openAIService: OpenAIProvider

    public var contextType: String { "emotion" }

    public init(openAIService: OpenAIProvider) {
        self.openAIService = openAIService
    }

    public func provideContext(for prompt: String) async throws -> [String: Any] {
        let systemPrompt = """
        Determine the user's emotional state from the text and respond in JSON:

        {
          "mood": "stressed", // or "relaxed", "excited", "neutral"
          "tone": "supportive" // or "professional", "friendly"
        }

        Only return valid JSON.
        """

        let jsonString = try await openAIService.send(systemPrompt: systemPrompt, userPrompt: prompt)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "EmotionContext", code: 1)
        }

        let decoded = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]

        return [
            "type": contextType,
            "data": decoded
        ]
    }
}
