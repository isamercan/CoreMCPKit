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
        VStack(alignment: .leading, spacing: 10) {
            Text("📌 Öne Çıkan Özellikler")
                .font(.headline)
                .padding(.bottom, 4)
            
            ForEach(features, id: \.name) { feature in
                if let name = feature.name {
                    let percentage = Int((feature.score ?? 0) * 100) ?? 0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(localizedFeatureName(name))
                                .font(.subheadline)
                            Spacer()
                            Text("\(percentage)%")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .bold()
                        }
                        
                        Text(featureExplanation(for: name, score: feature.score ?? 0))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func localizedFeatureName(_ name: String) -> String {
        switch name.lowercased() {
            case "location": return "Konum"
            case "food": return "Yemekler"
            case "pool": return "Havuz"
            case "staff": return "Personel"
            case "cleanliness": return "Temizlik"
            case "price": return "Fiyat"
            default: return name.capitalized
        }
    }
    
    private func featureExplanation(for feature: String, score: Double) -> String {
        switch feature.lowercased() {
            case "location": return "Konum çok beğeniliyor ve merkezi noktalara yakın."
            case "food": return "Lezzetli ve çeşitli yemek seçenekleri öne çıkıyor."
            case "pool": return "Havuz alanı geniş, temiz ve keyifli zaman sunuyor."
            case "staff": return "Çalışanlar yardımsever ve güler yüzlü bulunuyor."
            case "cleanliness": return "Temizlik seviyesi yüksek, kullanıcılar memnun."
            case "price": return "Fiyat/performans dengesi kullanıcılar tarafından olumlu değerlendiriliyor."
            default: return "Bu özellik hakkında olumlu geri bildirimler alınmış."
        }
    }
}

