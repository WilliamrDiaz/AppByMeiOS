//
//  ReviewRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol ReviewRepositoryProtocol {
    func addReview(review: Review) async throws
    func getReviews(professionalId: String) async throws -> [Review]
    func getUserReview(professionalId: String, userId: String) async throws -> Review?
}
