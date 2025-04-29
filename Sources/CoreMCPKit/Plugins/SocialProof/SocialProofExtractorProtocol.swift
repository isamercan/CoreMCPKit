//
//  SocialProofExtractorProtocol.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//

import Foundation
// MARK: - Provider Protocol
public protocol SocialProofExtractorProtocol {
    func fetchSocialProof(for hotelUrl: String, reviews: [String], userPreferences: UserPreferences?) async throws -> SocialProof
}
