//
//  HotelDetailResponse.swift
//  CoreMCPKitSampleApp
//
//  Created by İlker İsa Mercan on 30.04.2025.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let response = try? JSONDecoder().decode(Response.self, from: jsonData)

import Foundation

// MARK: - Response
struct Response: Codable {
    let result: Result?
}

// MARK: - Result
struct Result: Codable {
    let hotelID, name: String?
    let vndType, vndCode: String?
    let imageCount: Int?
    let images: [String]?
    let infos: [Info]?
    let reviews: Reviews?
        
    enum CodingKeys: String, CodingKey {
        case hotelID = "hotelId"
        case name, vndType, vndCode
        case imageCount, images, infos, reviews

    }
}

// MARK: - Info
struct Info: Codable {
    let title, startDate, endDate: String?
    let active: Bool?
    let generalInfo: GeneralInfo?
    let importantInfo: ImportantInfo?
    let facilityCategories: [FacilityCategory]?
}

// MARK: - FacilityCategory
struct FacilityCategory: Codable {
    let title: Title?
    let freeText: String?
    let facilities: [Facility]?
}

// MARK: - Facility
struct Facility: Codable {
    let label: String?
    let paid: Bool?
    let description: String?
}

// MARK: - Title
struct Title: Codable {
    let icon, label: String?
    let description: String?
}

// MARK: - GeneralInfo
struct GeneralInfo: Codable {
    let themes: [Title]?
    let generalInfoText: String?
    let facilities: [Facility]?
}

// MARK: - ImportantInfo
struct ImportantInfo: Codable {
    let checkInTime, checkOutTime, desc: String?
}



enum TypeEnum: String, Codable {
    case historical = "HISTORICAL"
    case nearby = "NEARBY"
    case transportation = "TRANSPORTATION"
}


// MARK: - Promotion
struct Promotion: Codable {
    let id: Int?
    let badgeType, type, name: String?
    let description: Description?
    let imageURL: String?
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id, badgeType, type, name, description
        case imageURL = "imageUrl"
        case icon
    }
}

// MARK: - Description
struct Description: Codable {
    let tag: String?
    let desc: [String]?
}

// MARK: - Reviews
struct Reviews: Codable {
    let average: Average?
    let scoreTypes, scoreAverages: [ScoreAverage]?
    let userReviews: [UserReview]?
    let hospitableFlags: [HospitableFlag]?
}

// MARK: - Average
struct Average: Codable {
    let score: Int?
    let name: String?
    let reviewCount: Int?
}

// MARK: - HospitableFlag
struct HospitableFlag: Codable {
    let type, name: String?
    let point: Int?
}

// MARK: - ScoreAverage
struct ScoreAverage: Codable {
    let name: String?
    let score: Int?
}

// MARK: - UserReview
struct UserReview: Codable {
    let name, surname, reviewText, date: String?
    let recommendation: String?
    let score: Int?
    let guestType, scoreText: String?
    let roomName: String?
    let hotelReview: String?
    let ratingTypes: [ScoreAverage]?
}
