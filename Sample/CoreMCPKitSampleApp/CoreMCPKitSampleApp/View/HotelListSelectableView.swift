//
//  HotelListSelectableView.swift
//  CoreMCPKitSampleApp
//
//  Created by isa on 29.04.2025.
//

import SwiftUI
import CoreMCPKit


struct HotelListView: View {
    let hotels: [Hotel]
    let socialProofs: [String: SocialProof]
    let onSelect: (Hotel) -> Void

    var body: some View {
        List(hotels) { hotel in
            HotelCardView(hotel: hotel, socialProof: socialProofs[hotel.url ?? ""])
                .onTapGesture {
                    onSelect(hotel)
                }
        }
    }
}



struct HotelCardView: View {
    let hotel: Hotel
    let socialProof: SocialProof?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: hotel.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .cornerRadius(10)
                } else {
                    ProgressView()
                }
            }

            Text(hotel.hotelName ?? "Not Available")
                .font(.headline)

            HStack {
                Text("⭐️ \(hotel.rating)")
                Text("💬 \(hotel.commentCount)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            if let proof = socialProof {
                Divider()
                Text("💡 \(proof.summary)")
                    .font(.callout)
                Text("🔥 Popülerlik: \(Int(proof.popularityScore * 100))%")
                    .font(.footnote)
                    .foregroundColor(.orange)

                if let sentiment = proof.sentimentBreakdown {
                    Text("🙂 %\(Int(sentiment.positive)) • 😐 %\(Int(sentiment.neutral)) • 🙁 %\(Int(sentiment.negative))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical)
    }
}
