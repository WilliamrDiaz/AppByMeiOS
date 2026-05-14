//
//  ReviewRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class ReviewRepositoryImpl: ReviewRepositoryProtocol {
    private let db = Firestore.firestore()
    private let reviewsCollection = "reviews"

    func addReview(review: Review) async throws {
        try db.collection(reviewsCollection).addDocument(from: review)
    }

    func getReviews(professionalId: String) async throws -> [Review] {
        let snapshot = try await db.collection(reviewsCollection)
            .whereField("professionalId", isEqualTo: professionalId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Review.self) }
    }

    func getUserReview(professionalId: String, userId: String) async throws -> Review? {
        let snapshot = try await db.collection(reviewsCollection)
            .whereField("professionalId", isEqualTo: professionalId)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: Review.self)
    }
}
