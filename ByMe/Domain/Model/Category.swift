//
//  Category.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Category: Codable, Identifiable {
    // Al usar @DocumentID, Firebase mapea el nombre del documento aquí
    @DocumentID var id: String?
    var name: String = ""
}
