//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public final class EtsHotelSearchProvider: MCPContextProvider {
    private let service = EtsHotelService()
    public var contextType: String { "ets_hotel_search" }

    private let query: EtsHotelSearchQuery

    public init(query: EtsHotelSearchQuery) {
        self.query = query
    }

    public func provideContext(for prompt: String) async throws -> [String: Any] {
        let result = try await service.searchHotels(query: query)

        return [
            "type": contextType,
            "data": result
        ]
    }
}
