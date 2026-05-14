//
//  User.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String? // Captura el ID del documento automáticamente
    var name: String = ""
    var lastname: String = ""
    var email: String = ""
    var phone: String = ""
    var photoUrl: String = ""
    
    // En Swift, Codable mapeará "isProfessional" automáticamente
    var isProfessional: Bool = false
    
    var role: String = "user"
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    
    // Campos profesionales
    var category: String = ""
    var description: String = ""
    var experience: String = ""
    var rating: Double = 0.0
    var reviewCount: Int = 0
    var available: Bool = false
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}
