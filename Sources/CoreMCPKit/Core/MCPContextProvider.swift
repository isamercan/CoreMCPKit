//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public protocol MCPContextProvider {
    var contextType: String { get }
    func provideContext(for prompt: String) async throws -> [String: Any]
}
