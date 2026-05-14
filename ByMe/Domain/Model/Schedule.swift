//
//  Schedule.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Schedule: Codable, Identifiable {
    @DocumentID var id: String?
    var day: String = ""
    var hours: String = ""
}
