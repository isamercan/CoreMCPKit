//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public final class FlexibleContextProvider: MCPContextProvider {
    private let parser: PromptToFlexibleQueryParser
    private let etsService: EtsHotelServiceProvider

    public var contextType: String { "ets_hotel_search" }

    public init(parser: PromptToFlexibleQueryParser, etsService: EtsHotelServiceProvider) {
        self.parser = parser
        self.etsService = etsService
    }

    public func provideContext(for prompt: String) async throws -> [String: Any] {
        
        print("🚀 FlexibleContextProvider running for prompt: \(prompt)")
        
        // Prompt'tan sorgu çıkar
        let query = try await parser.parse(from: prompt)
        print("✅ Parsed FlexibleQuery: \(query)")

        // AutoComplete ile URL al
        guard let autoCompleteURL = try await etsService.autoComplete(query: query.location) else {
            throw NSError(domain: "FlexibleContextProvider", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No URL found from autoComplete for location \(query.location)"])
        }

        print("🔗 Found URL from AutoComplete: \(autoCompleteURL)")

        // ETS Sorgusu oluştur
        let etsQuery = EtsHotelSearchQuery(
            location: autoCompleteURL,
            type: query.type,
            checkInMonth: query.checkInMonth,
            checkInDate: query.checkInDate?.validateDate(),
            checkOutDate: query.checkOutDate?.validateDate(),
            adultCount: query.adultCount,
            childCount: query.childCount,
            childAges: query.childAges,
            url: autoCompleteURL,
            priceConcern: query.priceConcern
        )

        print("📋 ETS Query Prepared: \(etsQuery)")

        // ETS API ile otel arama
        let result = try await etsService.searchHotels(query: etsQuery)
        print("📦 ETS API Result: \(result)")

        return [
            "type": contextType,
            "data": result
        ]
    }

}

