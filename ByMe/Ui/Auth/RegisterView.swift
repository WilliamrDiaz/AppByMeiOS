//
//  RegisterView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    // Estados locales
    @State private var name = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false
    @State private var passwordError = ""
    
    var onNavigateToHome: () -> Void
    var onNavigateToLogin: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Título
                VStack(spacing: 8) {
                    Text("ByMe")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Nombre y Apellido en fila (HStack = Row)
                HStack(spacing: 12) {
                    customTextField(placeholder: "Nombre", text: $name)
                    customTextField(placeholder: "Apellido", text: $lastname)
                }
                
                // Email
                customTextField(placeholder: "Correo electrónico", text: $email, icon: "envelope")
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // Teléfono
                customTextField(placeholder: "Teléfono", text: $phone, icon: "phone")
                    .keyboardType(.phonePad)
                
                // Contraseña
                customPasswordField(placeholder: "Contraseña", text: $password, isVisible: $passwordVisible)
                
                // Confirmar Contraseña
                VStack(alignment: .leading) {
                    customPasswordField(placeholder: "Confirmar contraseña", text: $confirmPassword, isVisible: $confirmPasswordVisible)
                    
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading, 8)
                    }
                }
                
                // Botón Registrarse
                Button(action: {
                    if password != confirmPassword {
                        passwordError = "Las contraseñas no coinciden"
                    } else {
                        passwordError = ""
                        viewModel.registerWithEmail(
                            name: name,
                            lastname: lastname,
                            email: email,
                            phone: phone,
                            password: password
                        )
                    }
                }) {
                    Group {
                        if viewModel.uiState.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Registrarse").fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.top, 10)
                .disabled(viewModel.uiState.isLoading)
                
                // Ir a Login
                HStack {
                    Text("¿Ya tienes cuenta?")
                    Button("Iniciar Sesión") {
                        onNavigateToLogin()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
                
                // Error de Firebase
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
        .onChange(of: viewModel.uiState.isSuccess) { oldValue, newValue in
            if newValue {
                viewModel.resetState()
                onNavigateToHome()
            }
        }
    }
    
    // Componentes auxiliares para no repetir código
    @ViewBuilder
    private func customTextField(placeholder: String, text: Binding<String>, icon: String? = nil) -> some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon).foregroundColor(.gray)
            }
            TextField(placeholder, text: text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func customPasswordField(placeholder: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: "lock").foregroundColor(.gray)
            if isVisible.wrappedValue {
                TextField(placeholder, text: text)
            } else {
                SecureField(placeholder, text: text)
            }
            Button(action: { isVisible.wrappedValue.toggle() }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye").foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    RegisterView(
        onNavigateToHome: {
            print("Registro exitoso -> Home")
        },
        onNavigateToLogin: {
            print("Volviendo al Login")
        }
    )
}
