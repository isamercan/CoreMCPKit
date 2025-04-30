//
//  SocialProofCardView.swift
//  CoreMCPKitSampleApp
//
//  Created by isa on 29.04.2025.
//

import SwiftUI
import CoreMCPKit

public struct SocialProofCardView: View {
    public let socialProof: SocialProof

    public init(socialProof: SocialProof) {
        self.socialProof = socialProof
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Social Proof")
                .font(.title2)
                .bold()

            HStack {
                Text("⭐️ Rating: \(String(format: "%.1f", socialProof.averageRating))")
                Spacer()
                Text("💬 Reviews: \(socialProof.reviewCount)")
            }
            .font(.subheadline)

            Text("📝 Summary: \(socialProof.summary)")
                .font(.body)
                .padding(.vertical, 4)

            if let features = socialProof.highlightedFeatures {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏷️ Highlighted Features:")
                        .font(.headline)
                        .padding(.top, 8)

                    ForEach(features, id: \.name) { feature in
                        Text("- \(feature.name): \(feature.score, specifier: "%.1f") /5")
                            .font(.subheadline)
                    }
                }
            }

            HStack {
                Text("📈 Popularity: \(String(format: "%.2f", socialProof.popularityScore))")
                Spacer()
                if let trend = socialProof.trendingStatus {
                    Text("📊 Trend: \(trend.rawValue)")
                }
            }
            .font(.subheadline)
            .padding(.top, 8)

            if let personalizedSummary = socialProof.personalizedSummary {
                Text("🎯 Personalized Tip: \(personalizedSummary)")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 6)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
