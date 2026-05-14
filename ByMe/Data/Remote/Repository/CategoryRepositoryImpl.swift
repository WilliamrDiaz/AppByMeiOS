//
//  CategoryRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class CategoryRepositoryImpl: CategoryRepositoryProtocol {
    private let db = Firestore.firestore()

    func getCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Category.self) }
    }
}
