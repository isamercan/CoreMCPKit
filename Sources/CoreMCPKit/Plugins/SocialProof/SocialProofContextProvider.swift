//
//  SocialProofContextProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation
// MARK: - Context Provider (MCPContextProvider)

public final class SocialProofContextProvider: MCPContextProvider {
    private let provider: SocialProofProviderProtocol
    public var contextType: String { "social_proof" }
    
    public init(provider: SocialProofProviderProtocol) {
        self.provider = provider
    }
    
    public func provideContext(for prompt: String) async throws -> [String: Any] {
        let dummyHotelId = UUID()
        
        // Şu an için örnek yorumlar
        let dummyReviews = [
            "Otel çok temizdi ve personel çok ilgiliydi.",
            "Manzarası mükemmeldi ama yemekler kötüydü.",
            "Odalar geniş ve rahattı, özellikle çocuklar için uygun."
        ]
        
        let preferences = UserPreferences(preferredAmenities: ["Havuz", "Temizlik"], budgetRange: (min: 100, max: 500))
        
        let socialProof = try await provider.fetchSocialProof(for: dummyHotelId, reviews: dummyReviews, userPreferences: preferences)
        
        let data = try JSONEncoder().encode(socialProof)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        return [
            "type": contextType,
            "data": json
        ]
    }
}
