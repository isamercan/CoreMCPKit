//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public struct EtsHotelSearchQuery: Codable {
    public let location: String
    public let type: String?
    public let checkInMonth: String?
    public let checkInDate: String?
    public let checkOutDate: String?
    public let adultCount: Int?
    public let childCount: Int?
    public let childAges: [Int]?
    public let url: String?
    public let priceConcern: Bool?

    public init(
        location: String,
        type: String? = nil,
        checkInMonth: String? = nil,
        checkInDate: String? = nil,
        checkOutDate: String? = nil,
        adultCount: Int? = nil,
        childCount: Int? = nil,
        childAges: [Int]? = nil,
        url: String? = nil,
        priceConcern: Bool? = nil
    ) {
        self.location = location
        self.type = type
        self.checkInMonth = checkInMonth
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.adultCount = adultCount
        self.childCount = childCount
        self.childAges = childAges
        self.url = url
        self.priceConcern = priceConcern
    }
}
