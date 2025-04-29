//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
import NaturalLanguage

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



class SocialProofProvider: SocialProofProviderProtocol {
    private let parser: PromptToFlexibleQueryParser
    private let etsService: EtsHotelServiceProvider
}



import Foundation
public final class SocialProofQueryParser {
    private let openAIService: OpenAIProvider
    private let cache = NSCache<NSString, SocialProof>()

    public init(openAIService: OpenAIProvider) {
        self.openAIService = openAIService
    }
    
    func fetchSocialProof( for hotelId: UUID, reviews: [String], userPreferences: UserPreferences?
    ) async throws -> SocialProof {
        if let cached = cache.object(forKey: hotelId.uuidString as NSString) {
            return cached
        }
        
        let preferencePrompt = userPreferences.map { prefs in
            """
            Kullanıcı şu özelliklere önem veriyor: \(prefs.preferredAmenities?.joined(separator: ", ") ?? "Yok").
            Bütçe aralığı: \(prefs.budgetRange?.min ?? 0)-\(prefs.budgetRange?.max ?? Double.infinity) USD.
            Bu tercihlere uygun bir kişiselleştirilmiş özet üret.
            """
        } ?? ""
        
        let prompt = """
        Aşağıdaki otel yorumlarını analiz et ve şu bilgileri JSON formatında döndür:
        {
            "reviewCount": sayı,
            "averageRating": 0-5 arası sayı,
            "summary": "Yorumların 1-2 cümlelik genel özeti",
            "popularityScore": 0-1 arası sayı,
            "highlightedFeatures": [{"name": "özellik", "score": 0-5 arası sayı}, ...] veya null,
            "sentimentBreakdown": {
                "positive": 0-100 arası yüzde,
                "neutral": 0-100 arası yüzde,
                "negative": 0-100 arası yüzde
            },
            "trendingStatus": "İyileşiyor" | "Sabit" | "Geriliyor" veya null,
            "personalizedSummary": "Kullanıcı tercihlerine göre 1-2 cümlelik özet" veya null
        }
        Yorumlar:
        \(reviews.joined(separator: "\n"))
        \(preferencePrompt)
        Örnek:
        Yorumlar: ["Çok temiz!", "Personel kaba."]
        Tercihler: Kullanıcı temizlik önemsiyor.
        Çıktı: {
            "reviewCount": 2,
            "averageRating": 3.5,
            "summary": "Temizlik övülse de personel eleştirilmiş.",
            "popularityScore": 0.6,
            "highlightedFeatures": [{"name": "Temizlik", "score": 4.5}],
            "sentimentBreakdown": {"positive": 50, "neutral": 0, "negative": 50},
            "trendingStatus": "Sabit",
            "personalizedSummary": "Temizlik konusunda olumlu yorumlar var."
        }
        """
        
        do {
            let jsonString = try await llmService.generateResponse(prompt: prompt)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw SocialProofError.invalidJSON
            }
            
            let decoder = JSONDecoder()
            let socialProof = try decoder.decode(SocialProof.self, from: jsonData)
            
            cache.setObject(socialProof, forKey: hotelId.uuidString as NSString)
            return socialProof
        } catch {
            return SocialProof(
                reviewCount: reviews.count,
                averageRating: 3.0,
                summary: "Yorumlar analiz edilemedi.",
                popularityScore: 0.5,
                highlightedFeatures: nil,
                sentimentBreakdown: SentimentBreakdown(positive: 50, neutral: 50, negative: 0),
                trendingStatus: nil,
                personalizedSummary: nil
            )
        }
    }
    
    
    public func parse(from userPrompt: String) async throws -> SocialProof {
        let systemPrompt = """
        You are an assistant that extracts structured hotel or villa search parameters from the user's request.
        
        Respond ONLY with JSON in this exact format:
        
        {
          "location": "<city>",
          "type": "<otel or villa>",
          "checkInDate": "YYYY-MM-DD or null",
          "checkOutDate": "YYYY-MM-DD or null",
          "adultCount": number,
          "childCount": number,
          "childAges": [],
          "url": "<category-url>",
          "priceConcern": true or false
        }
        
        STRICT RULES:
        1. ONLY return valid JSON. No text or comments.
        2. location: Use the EXACT city from the prompt (e.g., 'Ankara').
        3. type: Detect 'otel' or 'villa', default to 'otel'.
        4. Dates MUST always be in the FUTURE, at least 3 days after today (2025 or later). Never return past dates.
        5. If any given date is in the past, replace it with a valid date at least 3 days from today.
        6. If 'haftasonu' (weekend) is mentioned:
           - Calculate the next possible Saturday (>= 3 days from today).
           - checkInDate: That Saturday.
           - checkOutDate: The following Sunday (1-night stay).
        7. If 'önümüzdeki hafta' (next week) is mentioned:
           - Calculate the first available day in next week (>= 3 days from today).
           - Set checkInDate and checkOutDate 2-4 days apart, both in next week.
        8. If NO specific date, month, or 'haftasonu' is mentioned:
           - Set checkInDate to 3 days from today.
           - Set checkOutDate to 4 days from today.
        9. If '1 gecelik' is mentioned, checkOutDate must be exactly 1 day after checkInDate, respecting all future date rules.
        10. adultCount: At least 2. Default to 2 if not provided.
        11. url: Construct from location and type (e.g., 'Istanbul-Otelleri' or 'Istanbul-Villalari').
        12. priceConcern: true if user mentions budget, cheap, affordable.
        13. All dates MUST be in the future, at least 3 days from today.
        
        Make sure all dates are valid and realistic future dates.
        """
        
        let rawLLMResponse = try await openAIService.send(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
        // Doğrudan fonksiyon çağır
        let cleanedJSON = cleanedJSONString(rawLLMResponse)
        
        print("📊 Cleaned LLM JSON: \(cleanedJSON)")
        
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw NSError(domain: "LLMParser", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON String"])
        }
        
        let parsedQuery = try JSONDecoder().decode(FlexibleSearchQuery.self, from: jsonData)
        
        return parsedQuery
    }
    
    func cleanedJSONString(_ raw: String) -> String {
        var cleaned = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleaned.hasPrefix("```json") || cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return cleaned
    }
    
}
