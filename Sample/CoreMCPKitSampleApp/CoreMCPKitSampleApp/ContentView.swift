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
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let manager: MCPAgentManager

    init() {
        do {
            let apiKey = try Configuration.openAIApiKey
            let config = MCPConfiguration(openAIApiKey: apiKey)
            let openAI = OpenAIProvider(apiKey: config.openAIApiKey)
            let parser = PromptToFlexibleQueryParser(openAIService: openAI)
            let etsService = EtsHotelService()

            let tempManager = MCPAgentManager(config: config)
            tempManager.registerProvider(EmotionContextProvider(openAIService: openAI))
            tempManager.registerProvider(FlexibleContextProvider(parser: parser, etsService: etsService))
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
                    VStack(alignment: .leading, spacing: 16) {
                        if !hotels.isEmpty {
                            HotelListView(hotels: hotels, llmResponse: llmResponse)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }

                        if !isLoading && hotels.isEmpty && llmResponse.isEmpty && errorMessage == nil {
                            Text("No results yet. Please enter a request.")
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
        errorMessage = nil

        do {
            // 1. ETS Context çek
            let contexts = try await manager.respondWithContexts(to: userPrompt)

            // ETS Context’ten otelleri ayıkla
            if let etsContext = contexts.first(where: { ($0["type"] as? String) == "ets_hotel_search" }),
               let etsData = etsContext["data"] as? [String: Any],
               let resultDict = etsData["result"] as? [String: Any],
               let hotelsArray = resultDict["hotels"] as? [[String: Any]] {

                let etsJSON = try JSONSerialization.data(withJSONObject: hotelsArray, options: [])
                let parsedHotels = try JSONDecoder().decode([Hotel].self, from: etsJSON)

                let availableHotels = parsedHotels ?? []

                if availableHotels.isEmpty {
                    errorMessage = "No available hotels found for your request."
                } else {
                    hotels = availableHotels
                }

            } else {
                errorMessage = "No valid hotel data found."
            }

            // 2. LLM'den açıklama da al
            llmResponse = try await manager.respond(to: userPrompt)

        } catch {
            errorMessage = "❌ LLM ile ilgili bir hata oluştu: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

struct HotelListView: View {
    let hotels: [Hotel]
    let llmResponse: String
    
    init(hotels: [Hotel], llmResponse: String) {
        self.hotels = hotels
        self.llmResponse = llmResponse
        print("📊 Hotels count: \(hotels.count)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Otel Listesi
            ForEach(hotels) { hotel in
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: hotel.imageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .cornerRadius(10)
                        } else {
                            ProgressView()
                        }
                    }

                    Text(hotel.hotelName ?? "Not Available")
                        .font(.headline)

                    Text("⭐️ \(hotel.rating) | 💬 \(hotel.commentCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(hotel.locations ?? "Not Available")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            }

            // 2. LLM Yanıtı Liste SONUNDA
            if !llmResponse.isEmpty {
                Divider()
                Text(llmResponse)
                    .font(.body)
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        .padding()
    }
}
