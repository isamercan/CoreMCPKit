//
//  ReviewInsightManager.swift
//  CoreMCPKitSampleApp
//
//  Created by İlker İsa Mercan on 7.05.2025.
//


//
//  ReviewInsightManager.swift
//  MyApp
//
//  Created by isa on 07.05.2025.
//

import Foundation
import CoreMCPKit

/// Manages fetching of review insights for selected hotels on-demand.
///
/// This class uses `ReviewInsightContextProvider` to prepare the context before requesting insights from the LLM service.
/// It lazily fetches review insights only when the user selects a hotel, improving performance and minimizing unnecessary calls.
@MainActor
final class ReviewInsightManager {
    
    private let contextProvider: ReviewInsightContextProvider
    private let manager: MCPAgentManager
    
    /// Initializes the manager with a context provider and MCP manager.
    /// - Parameters:
    ///   - contextProvider: The context provider responsible for setting hotelCode.
    ///   - manager: The MCP agent manager used to get context-based responses.
    init(contextProvider: ReviewInsightContextProvider, manager: MCPAgentManager) {
        self.contextProvider = contextProvider
        self.manager = manager
        self.manager.registerProvider(contextProvider)
    }
    
    /// Fetches the review insight for a specific hotel, if available.
    ///
    /// - Parameters:
    ///   - hotelCode: The unique identifier for the hotel.
    ///   - prompt: The user query used to generate context.
    /// - Returns: A decoded `ReviewInsights` object, or nil if fetch fails.
    func fetchReviewInsight(for hotelCode: String, prompt: String) async -> ReviewInsights? {
        contextProvider.selectedHotelCode = hotelCode
        
        contextProvider.
        
        do {
            let contexts = try await manager.respondWithContexts(to: prompt)
            if let insightContext = contexts.first(where: { ($0["type"] as? String) == "review_insight" }),
               let dataDict = insightContext["data"] as? [String: Any],
               let reviewInsightDict = dataDict["insightProof"] as? [String: Any] {
                
                let jsonData = try JSONSerialization.data(withJSONObject: reviewInsightDict)
                var insight = try JSONDecoder().decode(ReviewInsights.self, from: jsonData)
                insight.hotelCode = hotelCode
                return insight
            }
        } catch {
            print("❌ ReviewInsight fetch failed for \(hotelCode): \(error)")
        }
        
        return nil
    }
}
