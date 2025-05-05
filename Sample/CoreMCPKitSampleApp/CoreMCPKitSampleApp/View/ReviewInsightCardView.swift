//
//  ReviewInsightCardView.swift
//  CoreMCPKitSampleApp
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import SwiftUI
import CoreMCPKit

struct ReviewInsightCardView: View {
    let insights: ReviewInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Başlık
            Text("🧠 Otel Yorum Analizi")
                .font(.headline)
            
            // Genel Ortalama Puan
            if let avg = insights.overallAverage {
                HStack {
                    Text("🔢 Genel Puan:")
                    Spacer()
                    Text(String(format: "%.0f/100", avg.score ?? 0))
                        .bold()
                        .foregroundColor(.primary)
                }
            }
            

            // Tavsiye Etme
            if let recommendation = insights.recommendationRate {
                HStack {
                    Text("👍 Tavsiye Oranı:")
                    Spacer()
                    Text("\(Int((recommendation ?? 0) * 100))%")
                        .bold()
                        .foregroundColor(.green)
                }
            }
            
           
            
            // Güçlü Yönler (Flags)
            if let flags = insights.flags, !flags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏅 Güçlü Yönler:")
                        .font(.subheadline)
                        .bold()
                    ForEach(flags) { flag in
                        HStack {
                            Text("• \(flag.name)")
                            Spacer()
                            Text("\(flag.point)")
                                .foregroundColor(.orange)
                        }
                        .font(.caption)
                    }
                }
            }
            
            // Son Kullanıcı Yorumları
            if let latestReviews = insights.latestReviews, !latestReviews.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🗣 Son Yorumlar:")
                        .font(.subheadline)
                        .bold()
                    
                    ForEach(latestReviews.prefix(2)) { review in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\"\(review.reviewText)\"")
                                .italic()
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text("- \(review.name), \(review.date)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
