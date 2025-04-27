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
    @State private var response: String = ""
    @State private var hotels: [Hotel] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let manager: MCPAgentManager

    init() {
        do {
            let apiKey = try Configuration.openAIApiKey
            let config = MCPConfiguration(openAIApiKey: apiKey)

            // 📦 MCP Agent Kurulumu
            let openAI = OpenAIProvider(apiKey: config.openAIApiKey)
            let parser = PromptToFlexibleQueryParser(openAIService: openAI)
            let etsService = EtsHotelService()

            let tempManager = MCPAgentManager(config: config)
            tempManager.registerProvider(FlexibleContextProvider(parser: parser, etsService: etsService))
            tempManager.registerProvider(EmotionContextProvider(openAIService: openAI))

            self.manager = tempManager
            print("✅ MCPAgentManager initialized successfully.")

        } catch {
            fatalError("❌ Failed to initialize MCPAgentManager: \(error.localizedDescription)")
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Type your request...", text: $userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    Task {
                        await handlePrompt()
                    }
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

                if !hotels.isEmpty {
                    HotelListView(hotels: hotels)
                } else if !response.isEmpty {
                    ScrollView {
                        Text(response)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let error = errorMessage {
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("ETS Hotel Finder")
        }
    }

    private func handlePrompt() async {
        guard !userPrompt.isEmpty else { return }
        isLoading = true
        response = ""
        hotels = []
        errorMessage = nil

        do {
            let resultString = try await manager.respond(to: userPrompt)
            response = resultString

            if let data = resultString.data(using: .utf8),
               let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let etsData = result["data"] as? [String: Any],
               let etsJSON = try? JSONSerialization.data(withJSONObject: etsData, options: []),
               let parsedHotels = try? JSONDecoder().decode(ETSHotelResponse.self, from: etsJSON) {
                hotels = parsedHotels.hotels ?? []
                print(parsedHotels.hotels?.forEach({$0.hotelName}))
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

    
    

import SwiftUI

struct HotelListView: View {
    let hotels: [Hotel]

    var body: some View {
        List(hotels) { hotel in
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: hotel.imageUrl ?? String())) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        ProgressView()
                    }
                }

                Text(hotel.hotelName ?? "Not Found hotel name")
                    .font(.headline)

                Text("⭐️ \(hotel.rating) | 💬 \(hotel.commentCount) yorum")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let firstRoom = (hotel.rooms ?? []).first {
                    Text("\(firstRoom.roomName) • \(firstRoom.price ?? 0, specifier: "%.2f") \(firstRoom.currency)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Text(hotel.locations ?? String("Not Found hotel locations"))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .listStyle(PlainListStyle())
    }
}
