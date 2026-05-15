//
//  ChatDetailViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class ChatDetailViewModel: ObservableObject {
    @Published var uiState = ChatDetailUiState()
    
    private let chatRepository = DependencyContainer.shared.chatRepository
    private let userRepository = DependencyContainer.shared.userRepository
    private let draftManager = DependencyContainer.shared.draftManager
    
    private var professionalId: String = ""
    private var chatExists: Bool = false

    func loadChat(chatId: String, professionalName: String) {
        // substringAfter("_") -> components(separatedBy: "_").last
        self.professionalId = chatId.components(separatedBy: "_").last ?? ""
        
        // Restaurar borrador si existe
        let draft = draftManager.getDraft(chatId: chatId)
        uiState.chatId = chatId
        uiState.professionalName = professionalName
        uiState.messageText = draft
        
        uiState.isLoading = true
        
        Task {
            guard let repo = chatRepository else {
                print("Error: ChatRepository no inicializado")
                uiState.isLoading = false
                return
            }
            
            for await messages in repo.getMessages(chatId: chatId) {
                self.chatExists = !messages.isEmpty
                self.uiState.messages = messages
                self.uiState.isLoading = false
                print("Mensajes recibidos en iOS: \(messages.count)")
            }
        }
    }

    func onMessageTextChange(_ text: String) {
        uiState.messageText = text
        // Guardar borrador
        draftManager.saveDraft(chatId: uiState.chatId, text: text, professionalName: uiState.professionalName)
    }

    func sendMessage() {
        let text = uiState.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let userId = currentUser.uid
        let chatId = uiState.chatId
        
        Task {
            let message = Message(
                senderId: userId,
                text: text,
                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
            )

            // Si el chat no existe, crearlo antes de enviar el mensaje
            if !chatExists {
                do {
                    if let userRepo = userRepository, let chatRepo = chatRepository {
                        let currentUserData = try await userRepo.getUser(userId: userId)
                        let professionalData = try await userRepo.getUser(userId: professionalId)
                        
                        let userName = "\(currentUserData.name) \(currentUserData.lastname)"
                        let profName = "\(professionalData.name) \(professionalData.lastname)"
                        
                        _ = try await chatRepo.getOrCreateChat(
                            userId: userId,
                            professionalId: professionalId,
                            userName: userName,
                            professionalName: profName
                        )
                        chatExists = true
                    }
                } catch { print("Error creando chat: \(error)") }
            }

            try? await chatRepository?.sendMessage(chatId: chatId, message: message)
            
            // Limpiar borrador y campo
            draftManager.clearDraft(chatId: chatId)
            uiState.messageText = ""
        }
    }

    func markAsRead() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Task {
            try? await chatRepository?.markAsRead(chatId: uiState.chatId, userId: userId)
        }
    }
}
