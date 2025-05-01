//
//  SocialProofContextProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//


import Foundation

// MARK: - Context Provider (MCPContextProvider)

public final class SocialProofContextProvider: MCPContextProvider {
    // Dependencies
    private let provider: SocialProofExtractorProtocol
    private let preferenceExtractor: UserPreferencesExtractorProtocol
    private let etsService: EtsHotelServiceProvider
    
    // State
    public var selectedHotelUrl: String?
    
    // MCP Context Type
    public var contextType: String { "social_proof" }
    
    // MARK: - Init
    public init(
        provider: SocialProofExtractorProtocol,
        preferenceExtractor: UserPreferencesExtractorProtocol,
        etsService: EtsHotelServiceProvider
    ) {
        self.provider = provider
        self.preferenceExtractor = preferenceExtractor
        self.etsService = etsService
    }
    
    // MARK: - Provide Context
    public func provideContext(for prompt: String) async throws -> [String: Any] {
        guard let hotelUrl = selectedHotelUrl else {
            print("⚠️ SocialProofContextProvider: No selected hotel URL.")
            return [:]
        }

        // 1. Otel Detaylarını ve Yorumları Çek
        let detailDict = try await etsService.fetchHotelDetail(for: hotelUrl)
        print("✅ Hotel Detail: \(detailDict)")

        // 2. Kullanıcı Tercihlerini LLM'den Çek
        let preferences = try await preferenceExtractor.extractPreferences(from: prompt)
        print("✅ Extracted Preferences: \(preferences)")

        // 3. (Fake) Yorumları Üret
        let baseReviews = [
            "Otel çok temizdi, personel güler yüzlüydü.",
            "Yemekler harikaydı ama odalar biraz küçüktü.",
            "Konum çok merkeziydi, sahile çok yakındı.",
            "Wi-Fi biraz yavaştı ama genel olarak memnun kaldım.",
            "Havuz alanı çok geniş ve temizdi, çocuklar çok eğlendi.",
            "Kahvaltı açık büfe ve çok çeşitliydi.",
            "Fiyat/performans açısından çok iyi bir oteldi.",
            "Klima çalışmıyordu, biraz sorun yaşadık.",
            "Personel çözüm odaklıydı, sorunları hızlıca çözdüler.",
            "Deniz manzaralı odam harikaydı, tekrar gelirim."
        ]
        let fakeReviews = (0..<30).map { _ in baseReviews.randomElement()! }

        // 4. SocialProof Hesapla
        let socialProof = try await provider.fetchSocialProof(for: hotelUrl, reviews: fakeReviews, userPreferences: preferences)
        let socialProofJSON = try JSONEncoder().encode(socialProof)
        let socialProofDict = try JSONSerialization.jsonObject(with: socialProofJSON) as? [String: Any] ?? [:]

        // 5. Geri Dönüş
        return [
            "type": contextType,
            "data": [
                "socialProof": socialProofDict,
                "hotelDetail": detailDict,
                "preferences": preferences
            ]
        ]
    }


}
