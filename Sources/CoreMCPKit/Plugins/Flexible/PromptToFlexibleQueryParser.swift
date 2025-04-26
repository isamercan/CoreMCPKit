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

        Strict Rules:
        1. ONLY return valid JSON. No text, no comments.
        2. Use the EXACT city name mentioned in the prompt for the 'location' field (e.g., 'Ankara', not 'Ankara-Otelleri').
        3. Detect 'otel' or 'villa' from user wording. Default to 'otel' if not specified.
        4. If the user mentions 'haftasonu' (weekend) or similar terms, set checkInDate to the NEAREST future Saturday (at least 3 days after today) and checkOutDate to the following Sunday for a 1-night stay, unless specific dates or months are provided.
        5. If a specific month or date is mentioned, use those dates, ensuring they are in the future (2025 or later) and at least 3 days after today.
        6. If NO month, date, or 'haftasonu' is mentioned, set checkInDate and checkOutDate to null.
        7. Dates must always be in the future, at least 3 days after today. For 1-night stays (e.g., '1 gecelik'), checkOutDate must be the day after checkInDate. For other stays, checkOutDate should be 2-4 days after checkInDate.
        8. adultCount must be at least 2. Assume 2 if not specified.
        9. url must be based on location and type (e.g., 'Istanbul-Otelleri' for otel, 'Istanbul-Villalari' for villa).
        10. priceConcern is true if user mentions budget, cheap, affordable terms.
        11. If '1 gecelik' or similar is mentioned, prioritize a 1-night stay with checkOutDate as the next day, respecting other date rules (e.g., weekend for 'haftasonu').
        12. To select the nearest Saturday for 'haftasonu':
            - Start from today + 3 days.
            - Calculate the next Saturday by adding the required days based on the current day of the week.
            - Ensure the selected Saturday is the closest possible to today while respecting the 3-day future rule.
        """
      
        let jsonString = try await openAIService.send(systemPrompt: systemPrompt, userPrompt: userPrompt)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "PromptParse", code: 1)
        }

        return try JSONDecoder().decode(FlexibleSearchQuery.self, from: jsonData)
    }
}
