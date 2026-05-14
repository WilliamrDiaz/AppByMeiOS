//
//  Professional.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Professional: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var category: String = ""
    var description: String = ""
    var phone: String = ""
    var rating: Double = 0.0
    var reviewCount: Int = 0
    var imageUrl: String = ""
    var available: Bool = true
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}
