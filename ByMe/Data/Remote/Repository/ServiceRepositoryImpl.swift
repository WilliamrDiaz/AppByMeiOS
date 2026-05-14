//
//  ServiceRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class ServiceRepositoryImpl: ServiceRepositoryProtocol {
    private let db = Firestore.firestore()

    func getServices(userId: String) async throws -> [Service] {
        let snapshot = try await db.collection("users").document(userId).collection("services").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Service.self) }
    }

    func addService(userId: String, service: Service) async throws {
        let data: [String: Any] = [
            "name": service.name,
            "description": service.description
        ]
        try await db.collection("users").document(userId).collection("services").addDocument(data: data)
    }

    func deleteService(userId: String, serviceId: String) async throws {
        try await db.collection("users").document(userId).collection("services").document(serviceId).delete()
    }
}
