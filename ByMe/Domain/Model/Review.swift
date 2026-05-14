//
//  Review.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var professionalId: String = ""
    var userId: String = ""
    var userName: String = ""
    var rating: Double = 0.0
    var comment: String = ""
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}
