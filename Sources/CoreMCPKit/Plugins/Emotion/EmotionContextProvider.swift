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
        
        let cleaned = jsonString.cleanedJSON
        guard let data = cleaned.data(using: .utf8) else {
            throw NSError(domain: "EmotionParser", code: 1001, userInfo: nil)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            return [
                "type": contextType,
                "data": json
            ]
        } catch {
            throw NSError(domain: "Emotion Response Decode", code: 1001, userInfo: nil)
        }
    }
}
