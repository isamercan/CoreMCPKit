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
    
    var socialProofDict: [String: SocialProof] {
        Dictionary(uniqueKeysWithValues:
                    socialProofs.compactMap { proof in
            guard let url = proof.hotelUrl else { return nil }
            return (url, proof)
        }
        )
    }


    private let manager: MCPAgentManager
    private let socialProofProvider: SocialProofContextProvider
    
    init() {
        do {
            let apiKey = try Configuration.openAIApiKey
            let config = MCPConfiguration(openAIApiKey: apiKey)
            let openAI = OpenAIProvider(apiKey: config.openAIApiKey)
            let parser = PromptToFlexibleQueryParser(openAIService: openAI)
                        
            let preferences = UserPreferencesExtractor(llmService: openAI)
            let provider = SocialProofExtractor(llmService: openAI)
            let etsService = EtsHotelService()
            
            let socialContextProvider = SocialProofContextProvider(
                provider: provider,
                preferenceExtractor: preferences,
                etsService: etsService
            )

            let tempManager = MCPAgentManager(config: config)
            tempManager.registerProvider(EmotionContextProvider(openAIService: openAI))
            tempManager.registerProvider(FlexibleContextProvider(parser: parser, etsService: etsService))
            self.socialProofProvider = socialContextProvider
            tempManager.registerProvider(self.socialProofProvider)
            
            self.manager = tempManager
            
            
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
//                        if let socialProof = socialProof {
//                            SocialProofCardView(socialProof: socialProof)
//                        }

                        if !hotels.isEmpty {
                            HotelListView(
                                hotels: hotels,
                                socialProofs: socialProofDict
                            ) { selectedHotel in
                                Task {
                                    await selectHotelAndFetchProof(hotel: selectedHotel)
                                }
                            }
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
        
        do {
            let contexts = try await manager.respondWithContexts(to: userPrompt)
            
            // 🚩 ETS Hotels
            if let etsContext = contexts.first(where: { ($0["type"] as? String) == "ets_hotel_search" }),
               let etsData = etsContext["data"] as? [String: Any],
               let resultDict = etsData["result"] as? [String: Any],
               let hotelsArray = resultDict["hotels"] as? [[String: Any]] {
                
                let etsJSON = try JSONSerialization.data(withJSONObject: hotelsArray, options: [])
                do {
                    hotels = try JSONDecoder().decode([Hotel].self, from: etsJSON)
                    if !hotels.isEmpty {
                        await fetchAllSocialProofs(for: hotels)
                    }

                } catch {
                    print("❌ Hotel decoding error: \(error)")
                }
            }
            
            // 🚩 Social Proof
            if let socialContext = contexts.first(where: { ($0["type"] as? String) == "social_proof" }),
               let dataDict = socialContext["data"] as? [String: Any],
               let socialProofDict = dataDict["socialProof"] as? [String: Any] {
                
                let jsonData = try JSONSerialization.data(withJSONObject: socialProofDict)
                let proof = try JSONDecoder().decode(SocialProof.self, from: jsonData)
                socialProofs = [proof]
            }

            
            // 🚩 LLM Explanation
            llmResponse = try await manager.respond(to: userPrompt)
            
        } catch {
            errorMessage = "❌ Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchAllSocialProofs(for hotels: [Hotel]) async {
        socialProofs = []
        
        await withTaskGroup(of: SocialProof?.self) { group in
            for hotel in hotels {
                guard let url = hotel.url else { continue }
                
                group.addTask {
                    socialProofProvider.selectedHotelUrl = url
                    
                    do {
                        let contexts = try await manager.respondWithContexts(to: userPrompt)
                        if let socialContext = contexts.first(where: { ($0["type"] as? String) == "social_proof" }),
                           let dataDict = socialContext["data"] as? [String: Any],
                           let socialProofDict = dataDict["socialProof"] as? [String: Any] {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: socialProofDict)
                            var proof = try JSONDecoder().decode(SocialProof.self, from: jsonData)
                            proof.hotelUrl = url // important for mapping
                            return proof
                        }
                    } catch {
                        print("❌ SocialProof fetch failed for \(url): \(error.localizedDescription)")
                    }
                    
                    return nil
                }
            }
            
            for await proof in group {
                if let valid = proof {
                    socialProofs.append(valid)
                }
            }
        }
    }




    private func selectHotelAndFetchProof(hotel: Hotel) async {
        let hotelUrl = hotel.url ?? "Selectum-City-Atasehir"
        //guard  else { return }
        
        print("🏨 Selected Hotel URL: \(hotelUrl)")
        
        socialProofProvider.selectedHotelUrl = hotelUrl
        
        do {
            let contexts = try await manager.respondWithContexts(to: userPrompt)
            print("📦 Contexts: \(contexts)")
            
            if let socialProofContext = contexts.first(where: { ($0["type"] as? String) == "social_proof" }),
               let socialProofData = socialProofContext["data"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: socialProofData, options: [])
                print("📊 Decoding SocialProof JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")
                socialProof = try JSONDecoder().decode(SocialProof.self, from: jsonData)
            } else {
                print("⚠️ No social proof context found.")
            }
        } catch {
            errorMessage = "❌ SocialProof Error: \(error.localizedDescription)"
            print("❌ SocialProof Decode Error: \(error)")
        }
    }

}
