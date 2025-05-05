//
//  ReviewInsightFlag.swift
//  CoreMCPKit
//
//  Created by isa on 3.05.2025.
//

import Foundation

public struct ReviewInsightFlag: Codable, Identifiable {
    public var id: String { type ?? "SERVICE_NOT_VERIFIED" }
    
    public let type: String?         // Örn: "SERVICE_VERYGOOD"
    public let name: String?         // Örn: "Hizmeti Çok İyi"
    public let point: Int?           // Örn: 94
}

