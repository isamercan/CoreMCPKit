//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 27.04.2025.
//

import Foundation

public struct ETSHotelResponse: Codable {
    let hotels: [Hotel]?
    let totalHotelCount: Int?
    let totalHotelCountWithoutFilters: Int?
}

public struct Hotel: Codable, Identifiable {
    public var id: String { hotelId ?? UUID().uuidString }
    
    let hotelId: String?
    let hotelName: String?
    let imageUrl: String?
    let locations: String?
    //let rating: Double?
    let rooms: [Room?]?
    let commentCount: Int?
    let url: String?
    let state: String?
}

public struct Room: Codable {
    let roomName: String?
    let price: Double?
    let currency: String?
    let boardType: String?
    let discountRate: Int?
}
