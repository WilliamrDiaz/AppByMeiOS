//
//  Message.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    var senderId: String = ""
    var text: String = ""
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    var read: Bool = false
}
