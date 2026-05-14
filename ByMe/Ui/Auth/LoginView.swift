//
//  LoginView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI

struct LoginView: View {
    // 1. Conectamos con el ViewModel
    @StateObject private var viewModel = AuthViewModel()
    
    // 2. Estados locales para los campos
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    // 3. Callbacks de navegación definidos en MainNavigationView
    var onNavigateToHome: () -> Void
    var onNavigateToRegister: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 50)
                
                // Logo y Título
                VStack(spacing: 8) {
                    Text("ByMe")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Servicios a tu alrededor")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Campo Email
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Campo Contraseña
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if isPasswordVisible {
                        TextField("Contraseña", text: $password)
                    } else {
                        SecureField("Contraseña", text: $password)
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer(minLength: 10)
                
                // Botón Login Email
                Button(action: {
                    viewModel.loginWithEmail(email: email, password: password)
                }) {
                    Group {
                        if viewModel.uiState.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Iniciar Sesión")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.uiState.isLoading)
                
                // Divider "O"
                HStack {
                    VStack { Divider() }
                    Text("o").foregroundColor(.secondary).padding(.horizontal)
                    VStack { Divider() }
                }
                .padding(.vertical)
                
                // Botón Google
                Button(action: {
                    viewModel.loginWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill") // Icono de Google
                        Text("Continuar con Google")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                .foregroundColor(.primary)
                .disabled(viewModel.uiState.isLoading)
                
                Spacer(minLength: 20)
                
                // Ir a Registro
                HStack {
                    Text("¿No tienes cuenta?")
                    Button("Regístrate") {
                        onNavigateToRegister()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
                
                // Mensaje de Error
                if let error = viewModel.uiState.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.top)
                }
            }
            .padding(24)
        }
        // 4. LaunchedEffect(isSuccess) de Swift
        .onChange(of: viewModel.uiState.isSuccess) { oldValue, newValue in
            if newValue { 
                viewModel.resetState()
                onNavigateToHome()
            }
        }
    }
}

// Preview para ver el diseño en Xcode
#Preview {
    LoginView(onNavigateToHome: {}, onNavigateToRegister: {})
}
