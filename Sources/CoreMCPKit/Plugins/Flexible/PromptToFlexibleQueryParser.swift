//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
public final class PromptToFlexibleQueryParser {
    private let openAIService: OpenAIProvider

    public init(openAIService: OpenAIProvider) {
        self.openAIService = openAIService
    }

    public func parse(from userPrompt: String) async throws -> FlexibleSearchQuery {
        let systemPrompt = """
        Analyze the user's request and extract structured query information in JSON format:

        {
          "location": "Antalya",
          "type": "villa",
          "checkInMonth": "June",
          "priceConcern": true
        }

        Only return valid JSON.
        """

        let jsonString = try await openAIService.send(systemPrompt: systemPrompt, userPrompt: userPrompt)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "PromptParse", code: 1)
        }

        return try JSONDecoder().decode(FlexibleSearchQuery.self, from: jsonData)
    }
}
