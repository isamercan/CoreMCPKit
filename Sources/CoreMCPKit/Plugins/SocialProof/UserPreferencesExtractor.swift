//
//  UserPreferencesExtractor.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation

public final class UserPreferencesExtractor: UserPreferencesExtractorProtocol {
    private let llmService: LLMProvider
    
    public init(llmService: LLMProvider) {
        self.llmService = llmService
    }
    
    
    private func buildPrompt(from userPrompt: String) -> String {
        let systemPrompt = """
        You are a system that extracts structured hotel preferences from a user's travel request.
        
        Respond ONLY in the following strict JSON format:
        
        {
          "preferredAmenities": [String] or null,
          "budgetRange": {
            "min": Double,
            "max": Double
          } or null
        }
        
        Rules:
        - preferredAmenities: include amenities like "Havuz", "Temizlik", "Kahvaltı", "Deniz Manzarası" only if mentioned.
        - budgetRange: infer from keywords like "ekonomik", "uygun", "lüks", "maksimum 500", "1500 TL altı" etc. If no budget mentioned, return null.
        - Return only valid JSON. No explanation, no extra text.
        """
      
        return systemPrompt
    }
    
    public func extractPreferences(from userPrompt: String) async throws -> UserPreferences {
        let systemPrompt = buildPrompt(from: userPrompt)
        
        let fullPrompt = """
        User Prompt: "\(userPrompt)"
        """
        
        let response = try await llmService.send(systemPrompt: systemPrompt, userPrompt: fullPrompt)
        
        guard let jsonData = response.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }
        
        let dto = try JSONDecoder().decode(UserPreferences.self, from: jsonData)
        
        return UserPreferences(
            preferredAmenities: dto.preferredAmenities,
            budgetRange: dto.budgetRange
        )
    }
}
