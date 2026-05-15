//
//  UserEntity.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftData

@Model
final class UserEntity {
    @Attribute(.unique) var id: String
    var name: String
    var lastname: String
    var email: String
    var phone: String
    var photoUrl: String
    var isProfessional: Bool
    var role: String
    var createdAt: Int64
    var category: String
    var aboutMe: String
    var experience: String
    var rating: Double
    var reviewCount: Int
    var available: Bool
    var latitude: Double
    var longitude: Double

    init(id: String, name: String = "", lastname: String = "", email: String = "",
         phone: String = "", photoUrl: String = "", isProfessional: Bool = false,
         role: String = "user", createdAt: Int64 = 0, category: String = "",
         aboutMe: String = "", experience: String = "", rating: Double = 0.0,
         reviewCount: Int = 0, available: Bool = false, latitude: Double = 0.0,
         longitude: Double = 0.0) {
        self.id = id
        self.name = name
        self.lastname = lastname
        self.email = email
        self.phone = phone
        self.photoUrl = photoUrl
        self.isProfessional = isProfessional
        self.role = role
        self.createdAt = createdAt
        self.category = category
        self.aboutMe = aboutMe
        self.experience = experience
        self.rating = rating
        self.reviewCount = reviewCount
        self.available = available
        self.latitude = latitude
        self.longitude = longitude
    }
}
