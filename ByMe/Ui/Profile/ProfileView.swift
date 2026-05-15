//
//  ProfileView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    // Callbacks de navegación
    var onNavigateToLogin: () -> Void
    var onNavigateToProfessionalProfile: () -> Void
    var onNavigateToAbout: () -> Void
    var onNavigateToMessages: () -> Void
    var onNavigateToCalendar: () -> Void
    var onNavigateToHome: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.uiState.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 16)
                        
                        //  1. Foto de perfil con botón Editar 
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.blue)
                                )
                            
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 28, height: 28)
                                .shadow(radius: 2)
                                .overlay(
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14))
                                )
                        }
                        
                        Spacer(minLength: 8)
                        
                        //  2. Campos de Perfil 
                        VStack(spacing: 12) {
                            profileField(value: Binding(get: { viewModel.uiState.name }, set: { viewModel.onNameChange($0) }), placeholder: "Nombre")
                            profileField(value: Binding(get: { viewModel.uiState.lastname }, set: { viewModel.onLastnameChange($0) }), placeholder: "Apellido")
                            profileField(value: Binding(get: { viewModel.uiState.phone }, set: { viewModel.onPhoneChange($0) }), placeholder: "Teléfono")
                                .keyboardType(.phonePad)
                        }
                        
                        //  3. Botón "¿Quieres brindar un servicio?" 
                        Button(action: onNavigateToProfessionalProfile) {
                            Text("¿Quieres brindar un servicio?")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                        
                        //  4. Botones Guardar y Cancelar 
                        VStack(spacing: 12) {
                            Button(action: { viewModel.saveProfile() }) {
                                HStack {
                                    if viewModel.uiState.isSaving {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "checkmark")
                                        Text("Guardar")
                                    }
                                }
                                .font(.headline)
                                .frame(width: 200, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(24)
                            }
                            .disabled(viewModel.uiState.isSaving)
                            
                            Button(action: { onNavigateToHome() }) {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Cancelar")
                                }
                                .font(.headline)
                                .frame(width: 200, height: 50)
                                .foregroundColor(.gray.opacity(0.8))
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.4)))
                            }
                        }
                        .padding(.top, 24)
                        
                        // Mensaje de Error
                        if let error = viewModel.uiState.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(24)
                }
            }
            
            // Barra inferior
            HomeBottomBar(
                selectedTab: .profile,
                onHome: { onNavigateToHome() },
                onMessages: { onNavigateToMessages() },
                onCalendar: { onNavigateToCalendar() },
                onProfile: { } // Ya estamos aquí
            )
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: onNavigateToAbout) {
                        Label("Acerca de ByMe", systemImage: "info.circle")
                    }
                    Button(role: .destructive, action: {
                        try? Auth.auth().signOut()
                        onNavigateToHome()
                    }) {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                }
            }
        }
        .onChange(of: viewModel.uiState.isSuccess) { oldValue, newValue in
            if newValue { viewModel.resetSuccess() }
        }
    }
    
    // Componente para los campos del perfil
    private func profileField(value: Binding<String>, placeholder: String) -> some View {
        HStack {
            TextField(placeholder, text: value)
            Spacer()
            Image(systemName: "pencil")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 14))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            onNavigateToLogin: {},
            onNavigateToProfessionalProfile: {},
            onNavigateToAbout: {},
            onNavigateToMessages: {},
            onNavigateToCalendar: {},
            onNavigateToHome: {}
        )
    }
}
