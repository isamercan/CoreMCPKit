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
        You are an assistant that extracts structured hotel or villa search parameters from the user's request.

        Respond ONLY with JSON in this exact format:

        {
          "location": "<city>",
          "type": "<otel or villa>",
          "checkInDate": "YYYY-MM-DD or null",
          "checkOutDate": "YYYY-MM-DD or null",
          "adultCount": number,
          "childCount": number,
          "childAges": [],
          "url": "<category-url>",
          "priceConcern": true or false
        }

        STRICT RULES:
        1. ONLY return valid JSON. No text or comments.
        2. location: Use the EXACT city from the prompt (e.g., 'Ankara').
        3. type: Detect 'otel' or 'villa', default to 'otel'.
        4. Dates MUST always be in the FUTURE, at least 3 days after today (2025 or later). Never return past dates.
        5. If any given date is in the past, replace it with a valid date at least 3 days from today.
        6. If 'haftasonu' (weekend) is mentioned:
           - Calculate the next possible Saturday (>= 3 days from today).
           - checkInDate: That Saturday.
           - checkOutDate: The following Sunday (1-night stay).
        7. If 'önümüzdeki hafta' (next week) is mentioned:
           - Calculate the first available day in next week (>= 3 days from today).
           - Set checkInDate and checkOutDate 2-4 days apart, both in next week.
        8. If NO specific date, month, or 'haftasonu' is mentioned:
           - Set checkInDate to 3 days from today.
           - Set checkOutDate to 4 days from today.
        9. If '1 gecelik' is mentioned, checkOutDate must be exactly 1 day after checkInDate, respecting all future date rules.
        10. adultCount: At least 2. Default to 2 if not provided.
        11. url: Construct from location and type (e.g., 'Istanbul-Otelleri' or 'Istanbul-Villalari').
        12. priceConcern: true if user mentions budget, cheap, affordable.
        13. All dates MUST be in the future, at least 3 days from today.

        Make sure all dates are valid and realistic future dates.
        """
      
        let rawLLMResponse = try await openAIService.send(systemPrompt: systemPrompt, userPrompt: userPrompt)

        let cleanedJSON = rawLLMResponse.cleanedJSON

        print("📊 Cleaned LLM JSON: \(cleanedJSON)")

        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw NSError(domain: "LLMParser", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON String"])
        }

        let parsedQuery = try JSONDecoder().decode(FlexibleSearchQuery.self, from: jsonData)

        return parsedQuery
    }

}
