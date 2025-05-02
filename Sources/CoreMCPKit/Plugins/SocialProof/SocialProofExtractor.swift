//
//  SocialProofExtractor.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation

// MARK: - Social Proof Provider (LLM Destekli)

public final class SocialProofExtractor: SocialProofExtractorProtocol {
    private let llmService: LLMProvider
    private let cache = NSCache<NSString, SocialProof>()
    
    public init(llmService: LLMProvider) {
        self.llmService = llmService
    }
        
    public func fetchSocialProof(for hotelUrl: String, reviews: [String], userPreferences: UserPreferences?) async throws -> SocialProof {
        if let cached = cache.object(forKey: hotelUrl as NSString) {
            return cached
        }
        
        let prompt = buildPrompt(reviews: reviews, preferences: userPreferences)
        let jsonString = try await llmService.complete(prompt: prompt, contexts: [])
        let cleanedJSON = jsonString.cleanedJSON        
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw SocialProofError.invalidJSON
        }
        
        let decoded = try JSONDecoder().decode(SocialProof.self, from: jsonData)
        let enriched = SocialProof(
            hotelUrl: hotelUrl,
            reviewCount: decoded.reviewCount,
            averageRating: decoded.averageRating,
            summary: decoded.summary,
            popularityScore: decoded.popularityScore,
            highlightedFeatures: decoded.highlightedFeatures,
            sentimentBreakdown: decoded.sentimentBreakdown,
            trendingStatus: decoded.trendingStatus,
            personalizedSummary: decoded.personalizedSummary
        )
        
        cache.setObject(enriched, forKey: hotelUrl as NSString)
        return enriched
    }
    
    private func buildPrompt(reviews: [String], preferences: UserPreferences?) -> String {
        let preferenceSection = preferences.map { prefs in
            """
            Kullanıcı Tercihleri:
            Özellikler: \(prefs.preferredAmenities?.joined(separator: ", ") ?? "Belirtilmemiş")
            Bütçe Aralığı: \(prefs.budgetRange?.min ?? 0) - \(prefs.budgetRange?.max ?? 0) USD
            """
        } ?? ""
        
        return """
        Aşağıdaki otel yorumlarını analiz et ve şu formatta JSON döndür:
        
        {
            "reviewCount": Int,
            "averageRating": Double (0-5),
            "summary": String (kısa genel özet),
            "popularityScore": Double (0-1),
            "highlightedFeatures": [{"name": String, "score": Double}] veya null,
            "sentimentBreakdown": {"positive": %, "neutral": %, "negative": %},
            "trendingStatus": "İyileşiyor" | "Sabit" | "Geriliyor" veya null,
            "personalizedSummary": String veya null
        }
        
        Yorumlar:
        \(reviews.joined(separator: "\n"))
        
        \(preferenceSection)
        
        ❗️Kurallar:
        - Yalnızca geçerli JSON döndür.
        - Açıklama veya yazı ekleme.
        - Sentiment oranları toplamda %100 olmalı.
        - Özet 20-40 kelime arası olmalı.
        - Özellikler, sıkça geçen olumlu yorumlardan çıkarılmalı.
        - Trend durumu yorum trendlerine göre belirlenmeli.
        """
    }
}
