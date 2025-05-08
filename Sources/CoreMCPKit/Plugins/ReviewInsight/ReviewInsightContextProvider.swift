//
//  ReviewInsightContextProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

public final class ReviewInsightContextProvider: MCPContextProvider {
    private let provider: ReviewInsightProviding
    public var selectedHotelCode: String? // Set externally before calling `provideContext`
    
    public var contextType: String { "review_insight" }
    
    public init(provider: ReviewInsightProviding) {
        self.provider = provider
    }
    
    
    public func fetchInsights(for hotelCode: String) async throws -> ReviewInsights {
        let insights = try await provider.fetchInsights(for: hotelCode)
        printReviewInsights(insights)
        return insights
    }
    
    
    public func provideContext(for prompt: String) async throws -> [String: Any] {
        //let code = selectedHotelCode
        guard let code = selectedHotelCode else {
            print("⚠️ ReviewInsightContextProvider: No hotel code set.")
            return [:]
        }
        
        let insights = try await provider.fetchInsights(for: code)
        printReviewInsights(insights)

        let encoded = try JSONEncoder().encode(insights)
        let dict = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] ?? [:]
        
        return [
            "type": contextType,
            "data": dict
        ]
    }
    
    func printReviewInsights(_ insights: ReviewInsights) {
        print("🧠 İncelenen Otel Kodu: \(insights.hotelCode ?? "Bilinmiyor")")
        print("⭐️ Ortalama Puan: \(String(format: "%.1f", insights.averageScore ?? 0.0))/100")
        print("🧾 Toplam Yorum Sayısı: \(insights.totalReviewCount ?? 0)")
        
        if let overall = insights.overallAverage {
            print("📊 Genel Ortalama (\(overall.name)): \(String(format: "%.1f", overall.score ?? 0))/100")
        }
        
        if let categoryScores = insights.categoryScores, !categoryScores.isEmpty {
            print("\n📈 Kategori Bazlı Puanlar:")
            for category in categoryScores {
                print("  • \(category.name): \(String(format: "%.1f", category.score ?? 0))/100")
            }
        }
        
        if let rate = insights.recommendationRate {
            print("\n👍 Tavsiye Etme Oranı: %\(Int(rate * 100))")
        }
        
        if let priceScore = insights.pricePerformanceScore {
            print("💸 Fiyat/Performans Skoru: \(String(format: "%.1f", priceScore))/100")
        }
        
        if let flags = insights.flags, !flags.isEmpty {
            print("\n🚩 Tanısal Bayraklar (AI Diagnostic Flags):")
            for flag in flags {
                let label = flag.name ?? flag.type ?? "Tanımsız"
                let category = flag.type ?? "Bilinmiyor"
                print("  • [\(flag.name ?? "Kategori Yok")] \(label) – \(flag.point ?? 0) puan")
            }
        }
        
        if let reviews = insights.latestReviews, !reviews.isEmpty {
            print("\n🗣 Son Kullanıcı Yorumları:")
            for review in reviews {
                print("""
                ---
                👤 İsim: \(review.name ?? "Bilinmiyor")
                📅 Tarih: \(review.date ?? "Tarih Yok")
                🧍 Misafir Türü: \(review.guestType ?? "Bilinmiyor")
                🛏 Oda: \(review.roomName ?? "Bilinmiyor")
                🧮 Puan: \(String(format: "%.1f", review.score ?? 0.0))/100
                💬 Yorum: \(review.reviewText ?? "")
                """)
            }
        }
    }


}
