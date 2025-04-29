//
//  UserPreferencesExtractorProtocol.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation
// MARK: - Provider Protocol
public protocol UserPreferencesExtractorProtocol {
    func extractPreferences(from userPrompt: String) async throws -> UserPreferences
}
