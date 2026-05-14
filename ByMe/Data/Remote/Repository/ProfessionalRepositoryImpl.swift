//
//  ProfessionalRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class ProfessionalRepository {
    private let db = Firestore.firestore()    
    private let collectionName = "professional"

    func getAllProfessionals() async -> [Professional] {
        do {
            let snapshot = try await db.collection(collectionName).getDocuments()
            
            // compactMap intenta convertir cada documento y elimina los nulos si fallan
            return snapshot.documents.compactMap { doc in
                try? doc.data(as: Professional.self)
            }
        } catch {
            print("Error al obtener profesionales: \(error)")
            return []
        }
    }

    func searchProfessionals(query: String) async -> [Professional] {
        do {
            let snapshot = try await db.collection(collectionName).getDocuments()
            
            let professionals = snapshot.documents.compactMap { doc in
                try? doc.data(as: Professional.self)
            }
            
            // Filtrado igual que en Kotlin (ignoreCase = true)
            return professionals.filter { professional in
                professional.name.localizedCaseInsensitiveContains(query) ||
                professional.category.localizedCaseInsensitiveContains(query)
            }
        } catch {
            print("Error en búsqueda de profesionales: \(error)")
            return []
        }
    }
}
