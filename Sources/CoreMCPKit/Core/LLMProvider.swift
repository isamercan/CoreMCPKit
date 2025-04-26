//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public protocol LLMProvider {
    func complete(prompt: String, contexts: [[String: Any]]) async throws -> String
}
