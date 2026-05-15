//
//  ProfileViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var uiState = ProfileUiState()
    
    private let getUserUseCase = DependencyContainer.shared.getUserUseCase
    private let updateUserUseCase = DependencyContainer.shared.updateUserUseCase
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        uiState.isLoading = true
        
        Task {
            do {
                let user = try await getUserUseCase?.execute(userId: userId)
                uiState.user = user
                uiState.name = user?.name ?? ""
                uiState.lastname = user?.lastname ?? ""
                uiState.phone = user?.phone ?? ""
                uiState.isLoading = false
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    func onNameChange(_ value: String) { uiState.name = value }
    func onLastnameChange(_ value: String) { uiState.lastname = value }
    func onPhoneChange(_ value: String) { uiState.phone = value }
    
    func saveProfile() {
        guard let user = uiState.user else { return }
        
        uiState.isSaving = true
        uiState.errorMessage = nil
        
        Task {
            do {
                var updatedUser = user
                updatedUser.name = uiState.name
                updatedUser.lastname = uiState.lastname
                updatedUser.phone = uiState.phone
                
                try await updateUserUseCase?.execute(user: updatedUser)
                
                uiState.isSaving = false
                uiState.isSuccess = true
            } catch {
                uiState.isSaving = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetSuccess() { uiState.isSuccess = false }
}
