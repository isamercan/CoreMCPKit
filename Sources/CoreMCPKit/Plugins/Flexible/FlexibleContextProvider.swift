//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
public final class FlexibleContextProvider: MCPContextProvider {
    private let parser: PromptToFlexibleQueryParser

    public var contextType: String { "accommodation_search" }

    public init(parser: PromptToFlexibleQueryParser) {
        self.parser = parser
    }

    public func provideContext(for prompt: String) async throws -> [String: Any] {
        let query = try await parser.parse(from: prompt)

        return [
            "type": contextType,
            "data": [
                "location": query.location,
                "type": query.type ?? "",
                "check_in_month": query.checkInMonth ?? "",
                "price_concern": query.priceConcern ?? false
            ]
        ]
    }
}
