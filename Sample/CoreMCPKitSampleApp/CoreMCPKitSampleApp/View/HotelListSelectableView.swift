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
    let onTap: (Hotel) async -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(hotels) { hotel in
                HotelCardView(
                    hotel: hotel,
                    socialProof: socialProofs[hotel.url ?? ""]
                )
                .padding(.horizontal)
                .onTapGesture {
                    Task {
                        await onTap(hotel)
                    }
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
                Text("⭐️ Rating: \(5)")
                Text("💬 \(hotel.commentCount ?? 0)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            // SocialProof varsa göster
            if let proof = socialProof {
                Divider()
                SocialProofCardView(socialProof: proof)
            }
        }
        .padding(.vertical)
    }
}
