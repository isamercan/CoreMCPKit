//
//  ReviewInsightExtractor.swift
//  CoreMCPKit
//
//  Created by isa on 3.05.2025.
//

import Foundation
// MARK: - Provider Protocol
public protocol ReviewInsightExtractorProtocol {
    func fetchReviewInsights(for hotelCode: String, reviews: [String]) async throws -> ReviewInsights
}

public final class ReviewInsightExtractor: ReviewInsightExtractorProtocol {
    private let llmService: LLMProvider
    
    public init(llmService: LLMProvider) {
        self.llmService = llmService
    }
        
    public func fetchReviewInsights(for hotelCode: String, reviews: [String]) async throws -> ReviewInsights {
        
        let prompt = buildUserPrompt(for: hotelCode, reviews: reviews)
        let jsonString = try await llmService.send(systemPrompt: self.systemPrompt, userPrompt: prompt)
        let cleanedJSON = jsonString.cleanedJSON
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }
        
        let decoded = try JSONDecoder().decode(ReviewInsights.self, from: jsonData)
        print(decoded)
        return decoded
    }
    
    
    private func buildUserPrompt(for hotelCode: String, reviews: [String]) -> String {
        
        return """
        Analyze the following user reviews and extract structured insights strictly conforming to the `ReviewInsights` model below.
        
        You must:
        - Analyze sentiment, scores, and key experiential highlights from each review.
        - Infer category-level scores (like Service, Cleanliness, Location, etc.) if clearly implied.
        - Extract diagnostic insight flags that summarize notable strengths or weaknesses.
        - Your `flags` field must now include not just the type and score, but also:
          - A human-readable name (localized, Turkish)
          - A related category (e.g., "Hizmet", "Konum", "Temizlik")
          This is your AI Diagnostic Matrix. Use your judgment to infer as many high-quality diagnostic signals as the reviews suggest.
        - Include a recommendation rate based on language patterns such as "recommend", "would return", or "never again".
        - Leave values null if no inference can reasonably be made.
        - Return only valid JSON. Do not add any text or explanation outside the JSON block.
        ---
        
        
        
        ---

        ## INPUT:

        Hotel Code: "\(hotelCode)"

        User Reviews:
        \"\"
        \(reviews)
        \"\"

        ---

        ## REQUIRED JSON OUTPUT STRUCTURE:

        {
          "hotelCode": "\(hotelCode)",
          "averageScore": float|null,                         // Inferred average score (0–100)
          "totalReviewCount": integer|null,                   // Total number of reviews provided
          "overallAverage": {
            "category": "Genel",
            "score": float                                    // Overall satisfaction inferred
          },
          "categoryScores": [
            { "category": "Hizmet", "score": float },
            { "category": "Temizlik", "score": float },
            { "category": "Konum", "score": float },
            { "category": "Yemek", "score": float },
            { "category": "Fiyat/Performans", "score": float }
          ],
          "recommendationRate": float|null,                   // 0.0–1.0 — Ratio of users likely to recommend
          "pricePerformanceScore": float|null,                // Inferred value-for-money score (0–100)
          "flags": [
            {
              "type": "<machine_code, e.g. 'SERVICE_VERYGOOD'>",     // Machine-readable diagnostic key
              "name": "<human-readable label, e.g. 'Hizmeti Çok İyi'>",  // Localized for display
              "category": "<e.g. 'Hizmet', 'Konum', 'Yemek'>",        // Related score category
              "point": integer (0–100)                                // Strength of signal or confidence
            }
          ],
          "latestReviews": [
            {
              "name": "A***",                          // Masked guest name
              "reviewText": "<original review text>",  // Full text of review
              "date": "YYYY Ay",                       // Inferred or given
              "guestType": "Aile" | "Çift" | "Tek Kişi" | "Grup", // Type of guest
              "score": float (0–100),                  // Review-specific score
              "roomName": null | string                // Room name if mentioned
            }
          ]
        }
        """

    }
    
    var systemPrompt: String {
        return """

        You are a high-precision AI agent designed to extract structured business insights from user reviews of hotels.

        Your job is to process raw natural language reviews and return a machine-parseable JSON output conforming exactly to the `ReviewInsights` model.

        Your output must be complete, structured, and reflect all explicitly stated or strongly implied information from the reviews — including emotion, guest type, score, and evaluation flags.

        Avoid hallucinations. If something is not mentioned, leave it null.

        All numeric scores must be normalized to a 0–100 scale. Sentiment and category-specific evaluations should be extracted as scoring flags when appropriate (e.g., "SERVICE_VERYGOOD" or "LOCATION_FAR").

        Respond only with valid JSON. No explanations or text outside of JSON.

        """
    }
}
