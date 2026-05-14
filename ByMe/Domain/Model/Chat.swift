//
//  Chat.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

struct Chat: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String = ""
    var professionalId: String = ""
    var userName: String = ""
    var professionalName: String = ""
    var lastMessage: String = ""
    var lastMessageTime: Int64 = 0
    var unreadCount: Int = 0
}
