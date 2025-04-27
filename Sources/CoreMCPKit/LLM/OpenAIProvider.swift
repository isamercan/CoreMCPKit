//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

/// A provider for interacting with the OpenAI API to perform chat completions.
public final class OpenAIProvider: LLMProvider {
    private let apiKey: String
    private let baseURL: URL
    private let model: String

    /// Initializes the OpenAI provider with the given API key and configuration.
    /// - Parameters:
    ///   - apiKey: The OpenAI API key for authentication.
    ///   - baseURL: The base URL for the OpenAI API (default: "https://api.openai.com/v1").
    ///   - model: The model to use for completions (default: "gpt-4o").
    public init(apiKey: String, baseURL: String = "https://api.openai.com/v1", model: String = "gpt-4o") {
        self.apiKey = apiKey
        self.baseURL = URL(string: baseURL)!
        self.model = model
    }

    /// Completes a prompt with optional contexts, returning the generated response.
    /// - Parameters:
    ///   - prompt: The user's prompt to send to the OpenAI API.
    ///   - contexts: An array of context dictionaries to include in the prompt.
    /// - Returns: The generated response from the OpenAI API.
    /// - Throws: An `OpenAIError` if the request fails or the response is invalid.
    public func complete(prompt: String, contexts: [[String: Any]]) async throws -> String {
        let contextString = try JSONSerialization.data(withJSONObject: contexts, options: .prettyPrinted)
        guard let contextJSON = String(data: contextString, encoding: .utf8) else {
            throw OpenAIError.encodingError
        }

        let fullPrompt = """
        User Prompt: \(prompt)
        
        Contexts:
        \(contextJSON)
        """

        
        let systemPrompt = """
        I want you to act as a travel guide. I will write you my location and you will suggest a place to visit near my location. In some cases, I will also give you the type of places I will visit. You will also suggest me places of similar type that are close to my first location. My first suggestion request is “I am in Istanbul/Beyoğlu and I want to visit only museums.” Reply in English using professional tone for everyone.
        """
        
        return try await send(systemPrompt: systemPrompt, userPrompt: fullPrompt)
    }

    /// Sends a system and user prompt to the OpenAI API and returns the response.
    /// - Parameters:
    ///   - systemPrompt: The system prompt to set the assistant's behavior.
    ///   - userPrompt: The user's prompt to process.
    /// - Returns: The generated response from the OpenAI API.
    /// - Throws: An `OpenAIError` if the request fails or the response is invalid.
    public func send(systemPrompt: String, userPrompt: String) async throws -> String {
        let requestBody = ChatCompletionRequest(
            model: model,
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: userPrompt)
            ]
        )

        let request = try createURLRequest(endpoint: "chat/completions", body: requestBody)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        #if DEBUG
        if let rawJson = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("📊 OpenAI Raw Response: \(rawJson)")
        }
        #endif

        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.emptyResponse
        }

        return content
    }

    /// Creates a URL request for the specified endpoint with the given body.
    /// - Parameters:
    ///   - endpoint: The API endpoint (e.g., "chat/completions").
    ///   - body: The encodable request body.
    /// - Returns: A configured `URLRequest`.
    /// - Throws: An error if the request cannot be created or encoded.
    private func createURLRequest<T: Encodable>(endpoint: String, body: T) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
}

/// Models for OpenAI API requests and responses.
extension OpenAIProvider {
    /// Represents a chat completion request to the OpenAI API.
    struct ChatCompletionRequest: Encodable {
        let model: String
        let messages: [Message]
    }

    /// Represents a message in the chat completion request.
    struct Message: Encodable {
        let role: String
        let content: String
    }

    /// Represents a chat completion response from the OpenAI API.
    struct ChatCompletionResponse: Decodable {
        let choices: [Choice]

        struct Choice: Decodable {
            let message: Message

            struct Message: Decodable {
                let content: String
            }
        }
    }
}

/// Errors that can occur when interacting with the OpenAI API.
public enum OpenAIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case emptyResponse
    case encodingError
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "OpenAI: Invalid response received from the server."
        case .httpError(let statusCode, let message):
            return "OpenAI HTTP Error \(statusCode): \(message)"
        case .emptyResponse:
            return "OpenAI returned an empty response."
        case .encodingError:
            return "OpenAI: Failed to encode request data."
        case .decodingError:
            return "OpenAI: Failed to decode response data."
        }
    }
}
