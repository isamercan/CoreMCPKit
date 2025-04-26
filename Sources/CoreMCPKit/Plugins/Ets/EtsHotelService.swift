//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public final class EtsHotelService: EtsHotelServiceProvider  {
    public init() {}

    public func searchHotels(query: EtsHotelSearchQuery) async throws -> [String: Any] {
        let url = URL(string: "https://www.etstur.com/services/api/search/hotels")!

        let requestBody: [String: Any] = [
            "checkInDate": query.checkInDate ?? "",
            "checkOutDate": query.checkOutDate ?? "",
            "adultCount": query.adultCount ?? 0,
            "childCount": query.childCount ?? 0,
            "childAges": query.childAges ?? [],
            "url": query.url ?? "Genel-Otelleri",
            "currency": "TRY",
            "limit": 20,
            "offset": 0
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        return json
    }
    
    public func autoComplete(query: String) async throws -> String? {
        // URL’yi oluştur
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.etstur.com/v2/autocomplete?q=\(encodedQuery)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        
        if let results = json["result"] as? [[String: Any]],
           let firstResult = results.first,
           let firstURL = firstResult["url"] as? String {
            return firstURL
        } else {
            return nil
        }
    }


}
