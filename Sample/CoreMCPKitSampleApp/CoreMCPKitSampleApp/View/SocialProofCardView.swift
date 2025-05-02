//
//  SocialProofCardView.swift
//  CoreMCPKitSampleApp
//
//  Created by isa on 29.04.2025.
//

import SwiftUI
import CoreMCPKit
import SwiftUI

struct SocialProofCardView: View {
    let socialProof: SocialProof
    
    var cleanSummary: String {
        if let summary = socialProof.summary, !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return summary.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return "Özet eklenmedi."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 \(cleanSummary)")
                .font(.body)
            
            HStack {
                Text("🔥 Popülerlik: %\(Int((socialProof.popularityScore ?? 0) * 100))")
                    .font(.footnote)
                    .foregroundColor(.orange)
                
                if let trend = socialProof.trendingStatus {
                    Label(trend.rawValue, systemImage: trendIcon(for: trend))
                        .font(.footnote)
                        .foregroundColor(trendColor(for: trend))
                }
            }
            
            if let sentiment = socialProof.sentimentBreakdown {
                SentimentView(sentiment: sentiment)
            }
            
            if let features = socialProof.highlightedFeatures, !features.isEmpty {
                HighlightedFeaturesView(features: features)
            }
            
            if let personal = socialProof.personalizedSummary, !personal.isEmpty {
                Divider()
                Text("🎯 Sana özel: \(personal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func trendColor(for status: TrendingStatus) -> Color {
        switch status {
            case .improving: return .green
            case .stable: return .gray
            case .declining: return .red
        }
    }
    
    private func trendIcon(for status: TrendingStatus) -> String {
        switch status {
            case .improving: return "arrow.up"
            case .stable: return "equal"
            case .declining: return "arrow.down"
        }
    }
}


struct SentimentView: View {
    let sentiment: SentimentBreakdown
    
    var body: some View {
        Text("🙂 %\(Int(sentiment.positive)) • 😐 %\(Int(sentiment.neutral)) • 🙁 %\(Int(sentiment.negative))")
            .font(.caption)
            .foregroundColor(.gray)
    }
}

struct HighlightedFeaturesView: View {
    let features: [Feature]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("📌 Öne Çıkanlar:")
                .font(.caption)
                .bold()
            
            ForEach(features, id: \.name) { feature in
                let name = feature.name ?? ""
                let scorePercent = Int((feature.score ?? 0) * 100) ?? 0
                
                HStack {
                    Text("• \(name)")
                    Spacer()
                    Text("\(scorePercent)%")
                        .foregroundColor(.blue)
                }
                .font(.caption)
            }

        }
        .padding(.top, 4)
    }
}
