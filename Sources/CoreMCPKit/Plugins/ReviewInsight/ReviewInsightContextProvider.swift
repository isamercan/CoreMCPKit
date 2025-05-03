//
//  ReviewInsightContextProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

public final class ReviewInsightContextProvider: MCPContextProvider {
    private let provider: ReviewInsightProviding
    public var selectedHotelCode: String? // Set externally before calling `provideContext`
    
    public var contextType: String { "review_insight" }
    
    public init(provider: ReviewInsightProviding = ReviewInsightProvider()) {
        self.provider = provider
    }
    
    public func provideContext(for prompt: String) async throws -> [String: Any] {
        guard let code = selectedHotelCode else {
            print("⚠️ ReviewInsightContextProvider: No hotel code set.")
            return [:]
        }
        
        let insights = try await provider.fetchInsights(for: code)
        let encoded = try JSONEncoder().encode(insights)
        let dict = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] ?? [:]
        
        return [
            "type": contextType,
            "data": dict
        ]
    }
}
