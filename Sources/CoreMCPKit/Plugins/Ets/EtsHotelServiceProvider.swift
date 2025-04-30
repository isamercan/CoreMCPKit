//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
public protocol EtsHotelServiceProvider {
    func searchHotels(query: EtsHotelSearchQuery) async throws -> [String: Any]
    func autoComplete(query: String) async throws -> String?
    func fetchComments(for hotelUrl: String) async throws -> [String] 
}
