//
//  HomeView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    // 1. Conectamos con el ViewModel
    @StateObject private var viewModel = HomeViewModel()
    
    // Callbacks de navegación
    var onNavigateToLogin: () -> Void
    var onNavigateToProfessionalDetail: (String) -> Void
    var onNavigateToProfile: () -> Void
    var onNavigateToMessages: () -> Void
    var onNavigateToCalendar: () -> Void

    // Configuración de la cuadrícula
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 1. Barra de búsqueda
                    SearchBar(text: Binding(
                        get: { viewModel.uiState.searchQuery },
                        set: { viewModel.onSearchQueryChange(query: $0) }
                    ))
                    .padding(.top, 16)

                    // 2. Card de Mapa
                    MapPlaceholder()

                    // 3. Título de Sección
                    Text("Profesionales")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top, 8)

                    // 4. Contenido Principal
                    if viewModel.uiState.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else if viewModel.uiState.professionals.isEmpty {
                        Text("No se encontraron profesionales")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        // Grid de profesionales
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.uiState.professionals) { professional in
                                ProfessionalCard(professional: professional) {
                                    onNavigateToProfessionalDetail(professional.id ?? "")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // 5. Barra de navegación inferior
            HomeBottomBar(
                onHome: { },
                onMessages: {
                    if Auth.auth().currentUser != nil { onNavigateToMessages() }
                    else { onNavigateToLogin() }
                },
                onCalendar: {
                    if Auth.auth().currentUser != nil { onNavigateToCalendar() }
                    else { onNavigateToLogin() }
                },
                onProfile: { onNavigateToProfile() }
            )
        }
        .navigationBarHidden(true)
    }
}

// Sub-componente: ProfessionalCard
struct ProfessionalCard: View {
    let professional: User
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Foto de perfil
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)

                if !professional.photoUrl.isEmpty {
                    AsyncImage(url: URL(string: professional.photoUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 4) {
                Text(professional.name)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
                
                Text(professional.category)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                    
                    Text(String(format: "%.1f", professional.rating))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onClick()
        }
    }
}

// Sub-componente: SearchBar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Buscar servicios...", text: $text)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }
}

// Sub-componente: MapPlaceholder 
struct MapPlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            Text("Explorar profesionales cercanos")
                .fontWeight(.medium)
            Text("Próximamente")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Sub-componente: BottomBar
struct HomeBottomBar: View {
    var onHome: () -> Void
    var onMessages: () -> Void
    var onCalendar: () -> Void
    var onProfile: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                BottomBarItem(icon: "house.fill", label: "Inicio", isSelected: true, action: onHome)
                BottomBarItem(icon: "tray.fill", label: "Mensajes", action: onMessages)
                BottomBarItem(icon: "calendar", label: "Citas", action: onCalendar)
                BottomBarItem(icon: "person.fill", label: "Perfil", action: onProfile)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(.systemBackground))
        }
    }
}

struct BottomBarItem: View {
    let icon: String
    let label: String
    var isSelected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? .blue : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView(onNavigateToLogin: {}, onNavigateToProfessionalDetail: { _ in }, onNavigateToProfile: {}, onNavigateToMessages: {}, onNavigateToCalendar: {})
}
