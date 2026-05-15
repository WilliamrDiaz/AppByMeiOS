//
//  ProfessionalDetailView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct ProfessionalDetailView: View {    let professionalId: String
    @StateObject private var viewModel = ProfessionalDetailViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Callbacks de navegación
    var onNavigateBack: () -> Void
    var onNavigateToLogin: () -> Void
    var onNavigateToChat: (String, String) -> Void
    var onNavigateToProfile: () -> Void = {}
    var onNavigateToMessages: () -> Void = {}
    var onNavigateToCalendar: () -> Void = {}
    var onNavigateToHome: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Contenido Principal
            if viewModel.uiState.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.uiState.professional != nil {
                // Separamos el contenido para el Preview
                ProfessionalDetailContent(
                    professional: viewModel.uiState.professional!,
                    reviews: viewModel.uiState.reviews,
                    services: viewModel.uiState.services,
                    schedules: viewModel.uiState.schedules,
                    selectedTab: viewModel.uiState.selectedTab,
                    onTabSelected: { viewModel.onTabSelected(index: $0) },
                    onContactClick: {
                        if Auth.auth().currentUser != nil {
                            _ = viewModel.uiState.professional!
                            /*let chatId = "\(user.uid)_\(prof.id ?? "")"
                            onNavigateToChat(chatId, "\(prof.name) \(prof.lastname)")*/
                        } else {
                            onNavigateToLogin()
                        }
                    }
                )
            } else {
                Text(viewModel.uiState.errorMessage ?? "No encontrado")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Barra de navegación inferior
            HomeBottomBar(
                onHome: { onNavigateToHome() },
                onMessages: { onNavigateToMessages() },
                onCalendar: { onNavigateToCalendar() },
                onProfile: { onNavigateToProfile() }
            )
        }
        .navigationTitle("Detalle del profesional")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onNavigateBack() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            viewModel.loadProfessional(professionalId: professionalId)
        }
    }
}

// El contenido interno
struct ProfessionalDetailContent: View {
    let professional: User
    let reviews: [Review]
    let services: [Service]
    let schedules: [Schedule]
    let selectedTab: Int
    var onTabSelected: (Int) -> Void
    var onContactClick: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. Header
                HStack(alignment: .top, spacing: 16) {
                    // Foto
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 110, height: 110)
                        
                        if !professional.photoUrl.isEmpty {
                            AsyncImage(url: URL(string: professional.photoUrl)) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: { ProgressView() }
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.blue)
                        }
                    }

                    // Información al lado de la foto
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(professional.name) \(professional.lastname)")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text(professional.category)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        // Fila de Rating
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", professional.rating))
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 14))
                            Text("\(professional.reviewCount) reseñas")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)

                        // Botón Contactar
                        Button(action: onContactClick) {
                            Text("Contactar")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(24)
                        }
                        .padding(.top, 4)
                    }
                }

                // 2. Descripción
                VStack(alignment: .leading, spacing: 6) {
                    Text("Descripción")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(professional.description.isEmpty ? "Sin descripción" : professional.description)
                        .font(.system(size: 14))
                        .lineSpacing(4)
                }

                // 3. Tabs como Chips
                HStack(spacing: 8) {
                    TabChip(label: "Servicios", icon: "briefcase", isSelected: selectedTab == 0) { onTabSelected(0) }
                    TabChip(label: "Horarios", icon: "calendar", isSelected: selectedTab == 1) { onTabSelected(1) }
                    TabChip(label: "Reseñas", icon: "star", isSelected: selectedTab == 2) { onTabSelected(2) }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

                // 4. Contenido del Tab
                switch selectedTab {
                case 0: servicesList
                case 1: schedulesList
                case 2: reviewsList
                default: EmptyView()
                }
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
    }

    // Listas de cada Tab
    private var servicesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Servicios").font(.title2).bold()
                Image(systemName: "briefcase").foregroundColor(.blue)
            }
            if services.isEmpty {
                Text("No hay servicios registrados").foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            } else {
                ForEach(services) { service in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.name).font(.headline)
                        Text(service.description).font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var schedulesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Horarios").font(.title2).bold()
                Image(systemName: "calendar").foregroundColor(.blue)
            }
            if schedules.isEmpty {
                Text("No hay horarios registrados").foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            } else {
                ForEach(schedules) { schedule in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(schedule.day).font(.headline)
                        Text(schedule.hours).font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var reviewsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reseñas").font(.title2).bold()
                Image(systemName: "star").foregroundColor(.blue)
            }
            if reviews.isEmpty {
                Text("No hay reseñas registradas").foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            } else {
                ForEach(reviews) { review in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(review.userName).bold()
                            Spacer()
                            Text("\(Int(review.rating)) ★").foregroundColor(.yellow)
                        }
                        Text(review.comment).font(.subheadline).foregroundColor(.secondary)
                        Divider().padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

// Componente Chip
struct TabChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.system(size: 13))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

// PREVIEW
#Preview {
    NavigationStack {
        ProfessionalDetailView(
            professionalId: "123",
            onNavigateBack: {},
            onNavigateToLogin: {},
            onNavigateToChat: { _, _ in }
        )
    }
}
