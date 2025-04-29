//
//  File.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation
// MARK: - Provider Protocol
public protocol SocialProofProviderProtocol {
    func fetchSocialProof(for hotelId: UUID, reviews: [String], userPreferences: UserPreferences?) async throws -> SocialProof
}
