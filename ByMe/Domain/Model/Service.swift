//
//  Service.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Service: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var description: String = ""
}
