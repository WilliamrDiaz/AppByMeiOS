//
//  ChatListView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    
    // Callbacks de navegación
    var onNavigateToChat: (String, String) -> Void
    var onNavigateToLogin: () -> Void
    var onNavigateToProfile: () -> Void
    var onNavigateToCalendar: () -> Void
    var onNavigateToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Contenido principal
            Group {
                if viewModel.uiState.isLoading && viewModel.uiState.chats.isEmpty && viewModel.uiState.pendingChats.isEmpty {
                    ProgressView("Cargando mensajes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.uiState.chats.isEmpty && viewModel.uiState.pendingChats.isEmpty {
                    emptyStateView
                } else {
                    chatsList
                }
            }
            
            // Barra inferior consistente con el resto de la app
            HomeBottomBar(
                onHome: onNavigateToHome,
                onMessages: { },
                onCalendar: onNavigateToCalendar,
                onProfile: onNavigateToProfile
            )
        }
        .navigationTitle("Mensajes")
        .navigationBarTitleDisplayMode(.inline)
        // Refrescamos borradores cada vez que la pantalla aparece
        .onAppear {
            viewModel.refreshDrafts()
        }
    }
    
    // Sub-vistas
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.badge.filled.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("No tienes mensajes aún")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Cuando contactes a un profesional, aparecerá aquí.")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatsList: some View {
        List {
            // 1. Mostrar Chats con Borradores Pendientes
            if !viewModel.uiState.pendingChats.isEmpty {
                Section(header: Text("Pendientes")) {
                    ForEach(viewModel.uiState.pendingChats) { chat in
                        ChatRow(
                            chat: chat,
                            draft: viewModel.uiState.drafts[chat.id ?? ""],
                            onClick: { onNavigateToChat(chat.id ?? "", chat.professionalName) }
                        )
                    }
                }
            }
            
            // 2. Mostrar Chats Reales de Firestore
            ForEach(viewModel.uiState.chats) { chat in
                ChatRow(
                    chat: chat,
                    draft: viewModel.uiState.drafts[chat.id ?? ""],
                    onClick: { onNavigateToChat(chat.id ?? "", chat.professionalName) }
                )
            }
        }
        .listStyle(.plain)
    }
}

// Componente: Fila de Chat
struct ChatRow: View {
    let chat: Chat
    let draft: String?
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 15) {
                // Avatar con inicial
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 55, height: 55)
                    .overlay(
                        Text(chat.professionalName.prefix(1).uppercased())
                            .font(.title3).bold()
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(chat.professionalName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Tiempo del último mensaje (si existe)
                        if chat.lastMessageTime > 0 {
                            Text(formatTime(chat.lastMessageTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Lógica de Mensaje vs Borrador
                    if let draftText = draft, !draftText.isEmpty {
                        HStack(spacing: 4) {
                            Text("Borrador:").font(.subheadline).bold().foregroundColor(.red)
                            Text(draftText).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                        }
                    } else {
                        Text(chat.lastMessage.isEmpty ? "No hay mensajes aún" : chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Indicador de no leído
                if chat.unreadCount > 0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // Helper para formatear la hora (milisegundos a HH:mm)
    private func formatTime(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
