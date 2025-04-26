//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public final class MCPAgentManager {
    private var contextProviders: [MCPContextProvider] = []
    private let llm: LLMProvider
    public let config: MCPConfiguration

    public init(config: MCPConfiguration) {
        self.config = config
        self.llm = OpenAIProvider(apiKey: config.openAIApiKey)
    }

    public func registerProvider(_ provider: MCPContextProvider) {
        contextProviders.append(provider)
    }

    public func respond(to prompt: String) async throws -> String {
        var allContexts: [[String: Any]] = []

        for provider in contextProviders {
            do {
                let context = try await provider.provideContext(for: prompt)
                allContexts.append(context)
            } catch {
                print("⚠️ \(provider.contextType) context failed: \(error)")
            }
        }

        return try await llm.complete(prompt: prompt, contexts: allContexts)
    }
}
