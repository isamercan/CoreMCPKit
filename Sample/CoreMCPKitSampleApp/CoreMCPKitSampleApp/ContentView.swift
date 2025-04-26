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
    @State private var response: String = "Enter your prompt."
    @State private var isLoading: Bool = false

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
            VStack(spacing: 20) {
                TextField("Type your request...", text: $userPrompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    Task {
                        await processPrompt()
                    }
                }) {
                    Text(isLoading ? "Processing..." : "Send")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading || userPrompt.isEmpty)
                .padding(.horizontal)

                ScrollView {
                    Text(response)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .navigationTitle("CoreMCPKit Sample")
        }
    }

    private func processPrompt() async {
        guard !userPrompt.isEmpty else { return }
        isLoading = true
        response = "Processing..."
        do {
            let result = try await manager.respond(to: userPrompt)
            response = result
        } catch {
            response = "❌ Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
