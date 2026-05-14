//
//  ChatRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class ChatRepositoryImpl: ChatRepositoryProtocol {    private let db = Firestore.firestore()
    private let chatsCollection = "chats"

    func getOrCreateChat(userId: String, professionalId: String, userName: String, professionalName: String) async throws -> Chat {
        let chatId = "\(userId)_\(professionalId)"
        let docRef = db.collection(chatsCollection).document(chatId)
        let doc = try await docRef.getDocument()

        if doc.exists, let chat = try? doc.data(as: Chat.self) {
            return chat
        } else {
            let newChat = Chat(
                userId: userId,
                professionalId: professionalId,
                userName: userName,
                professionalName: professionalName,
                lastMessage: "",
                lastMessageTime: Int64(Date().timeIntervalSince1970 * 1000),
                unreadCount: 0
            )
            try docRef.setData(from: newChat)
            return newChat
        }
    }
    
    func createChat(chat: Chat) async throws -> String {
        let docRef = try db.collection(chatsCollection).addDocument(from: chat)
        return docRef.documentID
    }
    
    func getChats(userId: String) -> AsyncStream<[Chat]> {
        AsyncStream { continuation in
            var combined = [String: Chat]()
            
            let updateCombined = { (snapshot: QuerySnapshot?, error: Error?) in
                guard let documents = snapshot?.documents else { return }
                for doc in documents {
                    if let chat = try? doc.data(as: Chat.self) {
                        combined[doc.documentID] = chat
                    }
                }
                let sortedChats = combined.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
                continuation.yield(Array(sortedChats))
            }

            let l1 = db.collection(chatsCollection).whereField("userId", isEqualTo: userId).addSnapshotListener(updateCombined)
            let l2 = db.collection(chatsCollection).whereField("professionalId", isEqualTo: userId).addSnapshotListener(updateCombined)

            continuation.onTermination = { _ in
                l1.remove()
                l2.remove()
            }
        }
    }

    func sendMessage(chatId: String, message: Message) async throws {
        try db.collection(chatsCollection).document(chatId).collection("messages").addDocument(from: message)
        try await db.collection(chatsCollection).document(chatId).updateData([
            "lastMessage": message.text,
            "lastMessageTime": message.timestamp
        ])
    }

    func getMessages(chatId: String) -> AsyncStream<[Message]> {
        AsyncStream { continuation in
            let listener = db.collection(chatsCollection).document(chatId).collection("messages")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    let messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
                    continuation.yield(messages)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }
    
    func markAsRead(chatId: String, userId: String) async throws {
        try await db.collection(chatsCollection).document(chatId).updateData([
            "unreadCount": 0
        ])
    }
}
