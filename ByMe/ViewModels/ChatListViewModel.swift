//
//  ChatListViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    
    @Published var uiState = ChatListUiState()
    
    // Dependencias desde el DependencyContainer
    private let getChatsUseCase = DependencyContainer.shared.getChatsUseCase
    private let draftManager = DependencyContainer.shared.draftManager

    init() {
        loadChats()
    }

    private func loadChats() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        uiState.isLoading = true
        
        Task {
            // En Swift consumimos el AsyncStream (equivalente al collect de Kotlin)
            if let useCase = getChatsUseCase {
                for await chats in useCase.execute(userId: userId) {
                    
                    // cargar borradores locales desde el Manager
                    let drafts = draftManager.getAllDrafts()
                    
                    // Actualizar el estado principal
                    self.uiState.chats = chats
                    self.uiState.drafts = drafts
                    self.uiState.isLoading = false
                    
                    // Refrescar los chats que solo existen localmente
                    refreshDrafts()
                }
            }
        }
    }

    func refreshDrafts() {
        let drafts = draftManager.getAllDrafts()
        
        // Obtenemos los IDs de los chats que ya existen en Firestore
        let existingChatIds = Set(uiState.chats.compactMap { $0.id })

        // Crear chats "fantasma" para aquellos borradores que no tienen un chat real todavía
        let pendingChats = drafts.keys
            .filter { !existingChatIds.contains($0) }
            .map { chatId in
                Chat(
                    id: chatId,
                    professionalName: draftManager.getDraftName(chatId: chatId),
                    lastMessageTime: 0
                )
            }

        uiState.drafts = drafts
        uiState.pendingChats = pendingChats
    }
}
