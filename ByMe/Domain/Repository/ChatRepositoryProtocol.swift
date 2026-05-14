//
//  ChatRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

protocol ChatRepositoryProtocol {
    func getOrCreateChat(userId: String, professionalId: String, userName: String, professionalName: String) async throws -> Chat
    func createChat(chat: Chat) async throws -> String
    func getChats(userId: String) -> AsyncStream<[Chat]>
    func sendMessage(chatId: String, message: Message) async throws
    func getMessages(chatId: String) -> AsyncStream<[Message]>
    func markAsRead(chatId: String, userId: String) async throws
}
