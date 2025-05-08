//
//  ContentView.swift
//  CoreMCPKitSampleApp
//
//  Created by isa on 26.04.2025.
//

import SwiftUI
import CoreMCPKit

struct ContentView: View {
    @State private var userPrompt: String = ""
    @State private var hotels: [Hotel] = []
    @State private var llmResponse: String = ""
    @State private var socialProof: SocialProof? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @State private var socialProofs: [SocialProof] = []
    @State private var reviewInsights: [ReviewInsights] = []
    @State private var reviewInsight: ReviewInsights?
    
    var socialProofDict: [String: SocialProof] {
        Dictionary(uniqueKeysWithValues:
                    socialProofs.compactMap { proof in
            guard let url = proof.hotelUrl else { return nil }
            return (url, proof)
        })
    }
    
    var reviewInsightsDict: [String: ReviewInsights] {
        Dictionary(uniqueKeysWithValues:
                    reviewInsights.compactMap { insight in
            guard let hotelCode = insight.hotelCode else { return nil }
            return (hotelCode, insight)
        })
    }
    
    private let etsManager: MCPAgentManager
    private let socialManager: MCPAgentManager
    private let reviewManager: MCPAgentManager
    private let socialProofProvider: SocialProofContextProvider
    private let reviewProvider: ReviewInsightContextProvider
    private let reviewInsightManager: ReviewInsightManager
    
    init() {
        do {
            let apiKey = try Configuration.openAIApiKey
            let config = MCPConfiguration(openAIApiKey: apiKey)
            let openAI = OpenAIProvider(apiKey: config.openAIApiKey)
            let etsService = EtsHotelService()
            
            let parser = PromptToFlexibleQueryParser(openAIService: openAI)
            
            let preferences = UserPreferencesExtractor(llmService: openAI)
            let socialProofExtractor = SocialProofExtractor(llmService: openAI)
            
            let socialContextProvider = SocialProofContextProvider(
                provider: socialProofExtractor,
                preferenceExtractor: preferences,
                etsService: etsService
            )
            
            let insightExtractor: ReviewInsightExtractorProtocol = ReviewInsightExtractor(llmService: openAI)
            let reviewProvider = ReviewInsightProvider(extractor: insightExtractor)
            let reviewContextProvider = ReviewInsightContextProvider(provider: reviewProvider)
            
            self.socialProofProvider = socialContextProvider
            self.reviewProvider = reviewContextProvider
            
            let etsManager = MCPAgentManager(config: config)
            etsManager.registerProvider(FlexibleContextProvider(parser: parser, etsService: etsService))
            
            let socialManager = MCPAgentManager(config: config)
            socialManager.registerProvider(socialContextProvider)
            
            let reviewManager = MCPAgentManager(config: config)
            reviewManager.registerProvider(reviewContextProvider)
            
            self.etsManager = etsManager
            self.socialManager = socialManager
            self.reviewManager = reviewManager
            self.reviewInsightManager = ReviewInsightManager(contextProvider: reviewContextProvider, manager: reviewManager)
            
        } catch {
            fatalError("Failed to initialize: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Describe your hotel needs...", text: $userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    Task { await handlePrompt() }
                }) {
                    Text(isLoading ? "Searching..." : "Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading || userPrompt.isEmpty)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if !hotels.isEmpty {
                            HotelListView(
                                hotels: hotels,
                                socialProofs: socialProofDict,
                                reviewInsights: reviewInsightsDict
                            ) { selectedHotel in
                                Task {
                                    await selectHotelAndFetchProof(hotel: selectedHotel)
                                }
                            }
                        }
                        
                        if let reviewInsight {
                            Spacer()
                            Divider()
                            ReviewInsightCardView(insights: reviewInsight)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        if !isLoading && hotels.isEmpty && socialProof == nil && llmResponse.isEmpty && errorMessage == nil {
                            Text("No results yet. Please enter a request.")
                                .foregroundColor(.gray)
                        }
                        
                        if !isLoading && hotels.isEmpty {
                            Text("No hotels found.")
                                .foregroundColor(.gray)
                        }
                        
                        if !isLoading && socialProof == nil {
                            Text("No SocialProof found.")
                                .foregroundColor(.gray)
                        }
                        
                        if !isLoading && reviewInsights.isEmpty {
                            Text("No Review Insights response found.")
                                .foregroundColor(.gray)
                        }
                        
                        if !isLoading && llmResponse.isEmpty {
                            Text("No LLM response found.")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Ets MCP Search")
        }
    }
    
    private func handlePrompt() async {
        guard !userPrompt.isEmpty else { return }
        isLoading = true
        hotels = []
        llmResponse = ""
        socialProof = nil
        errorMessage = nil
        reviewInsights = []
        
        do {
            let contexts = try await etsManager.respondWithContexts(to: userPrompt)
            
            if let etsContext = contexts.first(where: { ($0["type"] as? String) == "ets_hotel_search" }),
               let etsData = etsContext["data"] as? [String: Any],
               let resultDict = etsData["result"] as? [String: Any],
               let hotelsArray = resultDict["hotels"] as? [[String: Any]] {
                
                let etsJSON = try JSONSerialization.data(withJSONObject: hotelsArray, options: [])
                hotels = try JSONDecoder().decode([Hotel].self, from: etsJSON)
                
                for hotel in hotels {
                    Task {
                        await selectHotelAndFetchProof(hotel: hotel)
                    }
                }
            }
            
            llmResponse = try await etsManager.respond(to: userPrompt)
            
        } catch {
            errorMessage = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func selectHotelAndFetchProof(hotel: Hotel) async {
        guard let hotelUrl = hotel.url, let hotelCode = hotel.hotelCode else { return }
        
        socialProofProvider.selectedHotelUrl = hotelUrl
        
        
        do {
            let contexts = try await socialManager.respondWithContexts(to: userPrompt)
            if let socialContext = contexts.first(where: { ($0["type"] as? String) == "social_proof" }),
               let dataDict = socialContext["data"] as? [String: Any],
               let socialProofDict = dataDict["socialProof"] as? [String: Any] {
                
                let jsonData = try JSONSerialization.data(withJSONObject: socialProofDict)
                let proof = try JSONDecoder().decode(SocialProof.self, from: jsonData)
                socialProofs = [proof]
            }
        } catch {
            errorMessage = "❌ SocialProof Error: \(error.localizedDescription)"
        }
        
        if !reviewInsightsDict.keys.contains(hotelCode) {
            if let insight = await reviewInsightManager.fetchReviewInsight(for: hotelCode, prompt: userPrompt) {
                reviewInsights.append(insight)
                reviewInsight = insight
            }
        }
    }
}
