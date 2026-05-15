//
//  OfferServiceViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class OfferServiceViewModel: ObservableObject {
    @Published var uiState = OfferServiceUiState()

    private let categoryRepository = DependencyContainer.shared.categoryRepository
    private let serviceRepository = DependencyContainer.shared.serviceRepository
    private let scheduleRepository = DependencyContainer.shared.scheduleRepository
    private let userRepository = DependencyContainer.shared.userRepository

    let dayOptions = ["Lunes - Viernes", "Sábados", "Domingos y festivos"]
    let timeOptions = [
        "6:00", "7:00", "8:00", "9:00", "10:00", "11:00",
        "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
        "18:00", "19:00", "20:00"
    ]

    init() {
        loadCategories()
    }

    private func loadCategories() {
        uiState.isLoading = true
        Task {
            do {
                uiState.categories = try await categoryRepository?.getCategories() ?? []
                uiState.isLoading = false
            } catch {
                uiState.errorMessage = error.localizedDescription
                uiState.isLoading = false
            }
        }
    }

    func onCategorySelected(_ category: String) { uiState.selectedCategory = category }
    func onExperienceSelected(_ experience: String) { uiState.selectedExperience = experience }
    func onDescriptionChange(_ value: String) { uiState.description = value }
    func onDaySelected(_ day: String) { uiState.selectedDay = day }
    func onStartTimeSelected(_ time: String) { uiState.selectedStartTime = time }
    func onEndTimeSelected(_ time: String) { uiState.selectedEndTime = time }

    func addService(name: String, description: String) {
        let newService = Service(id: nil, name: name, description: description)
        uiState.services.append(newService)
    }

    func removeService(at index: Int) {
        uiState.services.remove(at: index)
    }

    func addSchedule() {
        guard !uiState.selectedDay.isEmpty, !uiState.selectedStartTime.isEmpty, !uiState.selectedEndTime.isEmpty else { return }
        let hours = "\(uiState.selectedStartTime) - \(uiState.selectedEndTime)"
        
        if let index = uiState.schedules.firstIndex(where: { $0.day == uiState.selectedDay }) {
            uiState.schedules[index].hours += "\n\(hours)"
        } else {
            uiState.schedules.append(Schedule(id: nil, day: uiState.selectedDay, hours: hours))
        }
        
        uiState.selectedDay = ""
        uiState.selectedStartTime = ""
        uiState.selectedEndTime = ""
    }

    func removeSchedule(at index: Int) {
        uiState.schedules.remove(at: index)
    }

    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if uiState.selectedCategory.isEmpty {
            uiState.errorMessage = "Selecciona una categoría"
            return
        }
        if uiState.selectedExperience.isEmpty {
            uiState.errorMessage = "Selecciona tu experiencia"
            return
        }

        uiState.isSaving = true
        uiState.errorMessage = nil

        Task {
            do {
                var user = try await userRepository?.getUser(userId: userId)
                user?.isProfessional = true
                user?.category = uiState.selectedCategory
                user?.experience = uiState.selectedExperience
                user?.description = uiState.description
                user?.role = "professional"

                try await userRepository?.updateUser(user: user ?? User())

                for service in uiState.services {
                    try await serviceRepository?.addService(userId: userId, service: service)
                }

                for schedule in uiState.schedules {
                    try await scheduleRepository?.addSchedule(userId: userId, schedule: schedule)
                }

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
