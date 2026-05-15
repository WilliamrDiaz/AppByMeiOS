//
//  ChatDetailView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct ChatDetailView: View {
    let chatId: String
    let professionalName: String
    var onNavigateBack: () -> Void
    
    @StateObject private var viewModel = ChatDetailViewModel()
    private let currentUserId = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        VStack(spacing: 0) {
            // 1. Contenido de mensajes
            if viewModel.uiState.isLoading && viewModel.uiState.messages.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.uiState.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == currentUserId
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                    }
                    // Auto-scroll
                    .onChange(of: viewModel.uiState.messages.count) { oldValue, newValue in
                        if let lastId = viewModel.uiState.messages.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }
            }
            
            // 2. Barra de entrada
            messageInputBar
        }
        .navigationTitle(professionalName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onNavigateBack() }) {
                    Image(systemName: "arrow.left").foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90)).foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.loadChat(chatId: chatId, professionalName: professionalName)
            viewModel.markAsRead()
        }
    }
    
    private var messageInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                // OutlinedTextField con 24.dp de redondeo
                TextField("Escribe un mensaje...", text: Binding(
                    get: { viewModel.uiState.messageText },
                    set: { viewModel.onMessageTextChange($0) }
                ), axis: .vertical)
                .lineLimit(1...3)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                
                // IconButton de enviar
                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.uiState.messageText.isEmpty ? .gray.opacity(0.3) : .blue)
                        .padding(8)
                }
                .disabled(viewModel.uiState.messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .shadow(radius: 1) // Elevación sutil de Surface
        }
    }
}

// Burbuja de mensaje personalizada
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 60) } // max width 280dp aprox
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    // Esquema de esquinas idéntico a RoundedCornerShape de Android
                    .cornerRadius(16, corners: [
                        .topLeft, .topRight,
                        isCurrentUser ? .bottomLeft : .bottomRight
                    ])
                
                Text(formatTime(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .gray.opacity(0.5))
            }
            
            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }
    
    private func formatTime(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Helper para esquinas individuales
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
