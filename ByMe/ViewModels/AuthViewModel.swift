//
//  AuthViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import UIKit
import GoogleSignIn
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // Inyectamos dependencias desde nuestro Singleton
    private let loginUseCase = DependencyContainer.shared.loginUseCase
    private let registerUseCase = DependencyContainer.shared.registerUseCase
    private let auth = Auth.auth()
    
    @Published var uiState = AuthUiState()
    
    var currentUser: FirebaseAuth.User? {
        return auth.currentUser
    }
    
    // MARK: - Login con Email
    func loginWithEmail(email: String, password: String) {
        uiState.isLoading = true
        uiState.errorMessage = nil
        
        Task {
            do {
                // El .execute() reemplaza al .invoke() de Kotlin
                try await loginUseCase?.execute(email: email, password: password)
                uiState.isLoading = false
                uiState.isSuccess = true
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Registro con Email
    func registerWithEmail(name: String, lastname: String, email: String, phone: String, password: String) {
        uiState.isLoading = true
        uiState.errorMessage = nil
        
        Task {
            do {
                try await registerUseCase?.execute(
                    name: name,
                    lastname: lastname,
                    email: email,
                    phone: phone,
                    password: password
                )
                uiState.isLoading = false
                uiState.isSuccess = true
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Google Sign-In
    // Nota: En iOS, GoogleSignIn requiere una interacción con la UI (UIViewController)
    func loginWithGoogle() {
        uiState.isLoading = true
                
        // 1. Obtener el rootViewController
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let window = windowScene?.windows.first { $0.isKeyWindow }
        
        guard let rootViewController = window?.rootViewController else {
            self.uiState.isLoading = false
            self.uiState.errorMessage = "Error de sistema!"
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            // Usamos Task con @MainActor para volver al hilo principal de forma segura
            Task { @MainActor in
                if let error = error {
                    self.uiState.isLoading = false
                    self.uiState.errorMessage = error.localizedDescription
                    return
                }

                guard let user = signInResult?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.uiState.isLoading = false
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                do {
                    try await Auth.auth().signIn(with: credential)
                    self.uiState.isLoading = false
                    self.uiState.isSuccess = true
                } catch {
                    self.uiState.isLoading = false
                    self.uiState.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            uiState = AuthUiState()
        } catch {
            print("Error al cerrar sesión: \(error)")
        }
    }
    
    func resetState() {
        uiState.isSuccess = false
        uiState.errorMessage = nil
    }
}
