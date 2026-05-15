//
//  ProfessionalDetailViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfessionalDetailViewModel: ObservableObject {
    
    // El estado que la UI va a observar
    @Published var uiState = ProfessionalDetailUiState()
    
    private let getUserUseCase = DependencyContainer.shared.getUserUseCase
    private let reviewRepository = DependencyContainer.shared.reviewRepository
    private let serviceRepository = DependencyContainer.shared.serviceRepository
    private let scheduleRepository = DependencyContainer.shared.scheduleRepository
    private let chatRepository = DependencyContainer.shared.chatRepository
    
    func loadProfessional(professionalId: String) {
        uiState.isLoading = true
        uiState.errorMessage = nil
        
        Task {
            do {
                // 1. Cargar el profesional
                let professional = try await getUserUseCase?.execute(userId: professionalId)
                uiState.professional = professional
                uiState.isLoading = false
                
                // 2. Cargar datos adicionales en paralelo (como haces con launch { })
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await self.loadReviews(professionalId: professionalId) }
                    group.addTask { await self.loadServices(userId: professionalId) }
                    group.addTask { await self.loadSchedules(userId: professionalId) }
                }
                
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func loadReviews(professionalId: String) async {
        if let reviews = try? await reviewRepository?.getReviews(professionalId: professionalId) {
            uiState.reviews = reviews
        }
    }
    
    private func loadServices(userId: String) async {
        if let services = try? await serviceRepository?.getServices(userId: userId) {
            uiState.services = services
        }
    }
    
    private func loadSchedules(userId: String) async {
        if let schedules = try? await scheduleRepository?.getSchedules(userId: userId) {
            uiState.schedules = schedules
        }
    }
    
    func onTabSelected(index: Int) {
        uiState.selectedTab = index
    }
    
    func createOrGetChat(userId: String, professionalId: String, userName: String, professionalName: String) {
        Task {
            _ = try? await chatRepository?.getOrCreateChat(
                userId: userId,
                professionalId: professionalId,
                userName: userName,
                professionalName: professionalName
            )
        }
    }
}
