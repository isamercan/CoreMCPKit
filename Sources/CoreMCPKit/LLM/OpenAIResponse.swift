//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public struct OpenAIResponse: Codable {
    public struct Choice: Codable {
        public struct Message: Codable {
            public let role: String
            public let content: String
        }
        public let message: Message
    }
    public let choices: [Choice]
}

