//
//  HomeViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    // El estado que la UI va a observar
    @Published var uiState = HomeUiState()
    
    // Inyectamos los casos de uso desde el contenedor de dependencias
    private let getProfessionalsUseCase = DependencyContainer.shared.getProfessionalsUseCase
    private let searchProfessionalsUseCase = DependencyContainer.shared.searchProfessionalsUseCase
    
    init() {
        loadProfessionals()
    }
    
    func loadProfessionals() {
        uiState.isLoading = true
        uiState.errorMessage = nil
        
        Task {
            do {
                // execute() es el equivalente al invoke() de Kotlin
                let professionals = try await getProfessionalsUseCase?.execute()
                uiState.professionals = professionals ?? []
                uiState.isLoading = false
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    func onSearchQueryChange(query: String) {
        uiState.searchQuery = query
        
        Task {
            if query.isEmpty {
                loadProfessionals()
            } else {
                uiState.isLoading = true
                uiState.errorMessage = nil
                
                do {
                    let professionals = try await searchProfessionalsUseCase?.execute(query: query)
                    uiState.professionals = professionals ?? []
                    uiState.isLoading = false
                } catch {
                    uiState.isLoading = false
                    uiState.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
