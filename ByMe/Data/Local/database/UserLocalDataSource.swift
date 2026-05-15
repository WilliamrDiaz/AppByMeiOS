//
//  UserLocalDataSource.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftData

@MainActor
class UserLocalDataSource {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insertUser(_ user: UserEntity) {
        print("Guardando usuario: ", user.id)
        
        do {
            modelContext.insert(user)
           
            try modelContext.save()
        } catch {
            print("Error guardando usuario: \(error)")
        }
    }

    func getUserById(_ id: String) -> UserEntity? {
        let predicate = #Predicate<UserEntity> { $0.id == id }
        let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    func getProfessionals() -> [UserEntity] {
        let predicate = #Predicate<UserEntity> { $0.isProfessional == true }
        let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteUser(id: String) {
        let predicate = #Predicate<UserEntity> { $0.id == id }
        try? modelContext.delete(model: UserEntity.self, where: predicate)
    }
    
    func deleteAll() {
        try? modelContext.delete(model: UserEntity.self)
    }
}
