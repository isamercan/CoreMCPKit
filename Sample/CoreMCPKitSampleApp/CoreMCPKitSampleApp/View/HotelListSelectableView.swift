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
    let onHotelSelected: (Hotel) async -> Void
    
    var body: some View {
        List(hotels) { hotel in
            HotelCardView(hotel: hotel, socialProof: socialProofs[hotel.url ?? ""])
                .onTapGesture {
                    Task {
                        await onHotelSelected(hotel)
                    }
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
                Text("⭐️ \(hotel.rating ?? 0)")
                Text("💬 \(hotel.commentCount ?? 0)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            if let proof = socialProof {
                Divider()
                Text("💡 \(proof.summary)")
                    .font(.callout)
                Text("🔥 Popülerlik: \(Int((proof.popularityScore ?? 0) * 100))%")
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
