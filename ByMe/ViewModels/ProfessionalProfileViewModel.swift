//
//  ProfessionalProfileViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class ProfessionalProfileViewModel: ObservableObject {
    
    @Published var uiState = ProfessionalProfileUiState()
    
    // Inyectamos desde el DependencyContainer
    private let userRepository = DependencyContainer.shared.userRepository
    private let serviceRepository = DependencyContainer.shared.serviceRepository
    private let scheduleRepository = DependencyContainer.shared.scheduleRepository
    
    // Opciones para los Pickers (Dropdowns en Android)
    let dayOptions = ["Lunes - Viernes", "Sábados", "Domingos y festivos"]
    let timeOptions = [
        "6:00", "7:00", "8:00", "9:00", "10:00", "11:00",
        "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
        "18:00", "19:00", "20:00"
    ]
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        uiState.isLoading = true
        
        Task {
            do {
                let user = try await userRepository?.getUser(userId: userId)
                uiState.user = user
                uiState.name = user?.name ?? ""
                uiState.lastname = user?.lastname ?? ""
                uiState.description = user?.description ?? ""
                
                // Cargar servicios y horarios en paralelo
                async let servicesTask = serviceRepository?.getServices(userId: userId)
                async let schedulesTask = scheduleRepository?.getSchedules(userId: userId)
                
                uiState.services = try await servicesTask ?? []
                uiState.schedules = try await schedulesTask ?? []
                uiState.isLoading = false
            } catch {
                uiState.isLoading = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Manejo de cambios
    func onNameChange(_ value: String) { uiState.name = value; uiState.hasChanges = true }
    func onLastnameChange(_ value: String) { uiState.lastname = value; uiState.hasChanges = true }
    func onDescriptionChange(_ value: String) { uiState.description = value; uiState.hasChanges = true }
    func onDaySelected(_ day: String) { uiState.selectedDay = day }
    func onStartTimeSelected(_ time: String) { uiState.selectedStartTime = time }
    func onEndTimeSelected(_ time: String) { uiState.selectedEndTime = time }
    
    // MARK: - Servicios
    func addService(name: String, description: String) {
        let newService = Service(id: nil, name: name, description: description)
        uiState.services.append(newService)
        uiState.hasChanges = true
    }
    
    func removeService(_ service: Service) {
        uiState.services.removeAll { $0.id == service.id && $0.name == service.name }
        uiState.hasChanges = true
    }
    
    // MARK: - Horarios
    func addSchedule() {
        guard !uiState.selectedDay.isEmpty, !uiState.selectedStartTime.isEmpty, !uiState.selectedEndTime.isEmpty else { return }
        
        let hours = "\(uiState.selectedStartTime) - \(uiState.selectedEndTime)"
        
        if let index = uiState.schedules.firstIndex(where: { $0.day == uiState.selectedDay }) {
            uiState.schedules[index].hours += "\n\(hours)"
        } else {
            uiState.schedules.append(Schedule(id: nil, day: uiState.selectedDay, hours: hours))
        }
        
        // Limpiar selección
        uiState.selectedDay = ""
        uiState.selectedStartTime = ""
        uiState.selectedEndTime = ""
        uiState.hasChanges = true
    }
    
    func removeSchedule(_ schedule: Schedule) {
        uiState.schedules.removeAll { $0.id == schedule.id && $0.day == schedule.day }
        uiState.hasChanges = true
    }
    
    // MARK: - Guardar
    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid, let user = uiState.user else { return }
        
        uiState.isSaving = true
        
        Task {
            do {
                var updatedUser = user
                updatedUser.name = uiState.name
                updatedUser.lastname = uiState.lastname
                updatedUser.description = uiState.description
                
                try await userRepository?.updateUser(user: updatedUser)
                
                // Guardar servicios nuevos 
                for service in uiState.services where service.id == nil {
                    try await serviceRepository?.addService(userId: userId, service: service)
                }
                
                // Guardar horarios nuevos
                for schedule in uiState.schedules where schedule.id == nil {
                    try await scheduleRepository?.addSchedule(userId: userId, schedule: schedule)
                }
                
                uiState.isSaving = false
                uiState.isSuccess = true
                uiState.hasChanges = false
            } catch {
                uiState.isSaving = false
                uiState.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetSuccess() { uiState.isSuccess = false }
}
