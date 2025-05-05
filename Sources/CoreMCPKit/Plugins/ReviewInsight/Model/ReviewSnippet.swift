//
//  ReviewSnippet.swift
//  CoreMCPKit
//
//  Created by isa on 3.05.2025.
//

import Foundation

public struct ReviewSnippet: Codable, Identifiable {
    public var id: String { "\(name)-\(date)" }
    
    public let name: String?         // Maskelenmiş isim (örn: "A***")
    public let reviewText: String?   // Yorumu
    public let date: String?         // Örn: "2025 Nisan"
    public let guestType: String?   // Örn: "Aile", "Çift"
    public let score: Double?       // Örn: 100.0
    public let roomName: String?    // Örn: "A Blok Kara Tarafı"
}
