//
//  UserRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class UserRepositoryImpl: UserRepositoryProtocol {
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
        
    func createUser(user: User) async throws {
        do {
            // .setData(from:) convierte automáticamente tu struct a JSON para Firestore
            try db.collection(usersCollection).document(user.id ?? "").setData(from: user)
            
            // Aquí va la lógica para guardar en local (SwiftData)
        } catch {
            throw error
        }
    }

    func getUser(userId: String) async throws -> User {
        // 1. Aquí intentarías buscar en local primero
        
        // 2. Buscar en Firestore
        let snapshot = try await db.collection(usersCollection).document(userId).getDocument()
        
        guard let user = try? snapshot.data(as: User.self) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
        }
        
        return user
    }

    func updateUser(user: User) async throws {
        try db.collection(usersCollection).document(user.id ?? "").setData(from: user, merge: false)
    }

    func getProfessionals() async throws -> [User] {
        let snapshot = try await db.collection(usersCollection)
            .whereField("isProfessional", isEqualTo: true)
            .getDocuments()
        
        // compactMap elimina los nulos si algún documento falla al convertirse
        let professionals = snapshot.documents.compactMap { doc -> User? in
            try? doc.data(as: User.self)
        }
        
        return professionals
    }

    func searchProfessionals(query: String) async throws -> [User] {
        let snapshot = try await db.collection(usersCollection)
            .whereField("isProfessional", isEqualTo: true)
            .getDocuments()
        
        let professionals = snapshot.documents.compactMap { doc -> User? in
            try? doc.data(as: User.self)
        }
        
        // Filtrado manual 
        return professionals.filter { user in
            user.name.localizedCaseInsensitiveContains(query) ||
            user.category.localizedCaseInsensitiveContains(query)
        }
    }
}
