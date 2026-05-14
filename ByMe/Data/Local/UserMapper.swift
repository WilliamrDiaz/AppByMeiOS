//
//  UserMapper.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

extension User {
    func toEntity() -> UserEntity {
        return UserEntity(
            id: id ?? "",
            name: name,
            lastname: lastname,
            email: email,
            phone: phone,
            photoUrl: photoUrl,
            isProfessional: isProfessional,
            role: role,
            createdAt: createdAt,
            category: category,
            aboutMe: description,
            experience: experience,
            rating: rating,
            reviewCount: reviewCount,
            available: available,
            latitude: latitude,
            longitude: longitude
        )
    }
}

extension UserEntity {
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            lastname: lastname,
            email: email,
            phone: phone,
            photoUrl: photoUrl,
            isProfessional: isProfessional,
            role: role,
            createdAt: createdAt,
            category: category,
            description: aboutMe,
            experience: experience,
            rating: rating,
            reviewCount: reviewCount,
            available: available,
            latitude: latitude,
            longitude: longitude
        )
    }
}
