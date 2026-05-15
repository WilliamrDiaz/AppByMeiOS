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
    private let localDataSource: UserLocalDataSource
    
    // El constructor recibe la base de datos local
    init(localDataSource: UserLocalDataSource) {
        self.localDataSource = localDataSource
    }
    
    func createUser(user: User) async throws {
        do {
            // .setData(from:) convierte automáticamente tu struct a JSON para Firestore
            try db.collection(usersCollection).document(user.id ?? "").setData(from: user)
            
            // 2. Guardar en local: Caché
            let entity = user.toEntity()
            localDataSource.insertUser(entity)
        } catch {
            throw error
        }
    }

    func getUser(userId: String) async throws -> User {
        // 1. Aquí intentarías buscar en local primero
        if let cached = localDataSource.getUserById(userId) {
            return cached.toDomain()
        }
        
        // 2. Buscar en Firestore
        let snapshot = try await db.collection(usersCollection).document(userId).getDocument()
        
        guard let user = try? snapshot.data(as: User.self) else {
            throw NSError(domain: "UserRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
        }
        
        // 3. Guardar en local para futuras consultas
        localDataSource.insertUser(user.toEntity())
        
        return user
    }

    func updateUser(user: User) async throws {
        print("actuazando usuario ", user.id ?? "")
        
        // Actualizar en remoto
        try db.collection(usersCollection).document(user.id ?? "").setData(from: user, merge: true)
        
        // Actualizar en local
        localDataSource.insertUser(user.toEntity())
    }

    func getProfessionals() async throws -> [User] {
        do{
            // 1. Intentar obtener de la red
            let snapshot = try await db.collection(usersCollection)
                .whereField("isProfessional", isEqualTo: true)
                .getDocuments()
            
            // compactMap elimina los nulos si algún documento falla al convertirse
            let professionals = snapshot.documents.compactMap { doc -> User? in
                try? doc.data(as: User.self)
            }
            
            // 2. Cachear profesionales en SwiftData
            for prof in professionals {
                localDataSource.insertUser(prof.toEntity())
            }
            
            return professionals
        } catch {
            // 3. Si falla la red, devolver lo que tengamos en local
            let cached = localDataSource.getProfessionals()
            return cached.map { $0.toDomain() }
        }
        
    }

    func searchProfessionals(query: String) async throws -> [User] {
        do {
            // Búsqueda en red con filtrado manual
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
        } catch {
            // Fallback a búsqueda local si no hay internet
            let cached = localDataSource.getProfessionals()
            return cached.map { $0.toDomain() }.filter { user in
                user.name.localizedCaseInsensitiveContains(query) ||
                user.category.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
