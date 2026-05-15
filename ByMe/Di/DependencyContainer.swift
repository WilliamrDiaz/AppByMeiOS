//
//  DependencyContainer.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import SwiftData
import FirebaseFirestore
import FirebaseAuth

@MainActor
class DependencyContainer {
    // Singleton para acceder desde toda la app
    static let shared = DependencyContainer()
    
    // Data Sources
    private var modelContext: ModelContext?
    private(set) var userLocalDataSource: UserLocalDataSource?
    
    // Repositories
    private(set) var userRepository: UserRepositoryProtocol?
    private(set) var chatRepository: ChatRepositoryProtocol?
    private(set) var reviewRepository: ReviewRepositoryProtocol?
    private(set) var appointmentRepository: AppointmentRepositoryProtocol?
    private(set) var serviceRepository: ServiceRepositoryProtocol?
    private(set) var scheduleRepository: ScheduleRepositoryProtocol?
    private(set) var categoryRepository: CategoryRepositoryProtocol?
    
    // Use Cases
    private(set) var loginUseCase: LoginUseCase?
    private(set) var registerUseCase: RegisterUseCase?
    private(set) var getUserUseCase: GetUserUseCase?
    private(set) var updateUserUseCase: UpdateUserUseCase?
    private(set) var getProfessionalsUseCase: GetProfessionalsUseCase?
    private(set) var searchProfessionalsUseCase: SearchProfessionalsUseCase?
    private(set) var getChatsUseCase: GetChatsUseCase?
    private(set) var getMessagesUseCase: GetMessagesUseCase?
    private(set) var sendMessageUseCase: SendMessageUseCase?

    private init() {} // init vacío, sin crear nada

    // Llamar desde el App con el ModelContext oficial de SwiftUI
    static func configure(modelContext: ModelContext) {
        guard shared.modelContext == nil else { return } // Evitar reinicializar
        shared.setup(modelContext: modelContext)
    }

    private func setup(modelContext: ModelContext) {
        self.modelContext = modelContext

        // 1. Data Source Local
        let userLocalDS = UserLocalDataSource(modelContext: modelContext)
        self.userLocalDataSource = userLocalDS

        // 2. Repositorios
        let userRepo = UserRepositoryImpl(localDataSource: userLocalDS)
        let chatRepo = ChatRepositoryImpl()
        let reviewRepo = ReviewRepositoryImpl()
        let appointmentRepo = AppointmentRepositoryImpl()
        let serviceRepo = ServiceRepositoryImpl()
        let scheduleRepo = ScheduleRepositoryImpl()
        let categoryRepo = CategoryRepositoryImpl()

        self.userRepository = userRepo
        self.chatRepository = chatRepo
        self.reviewRepository = reviewRepo
        self.appointmentRepository = appointmentRepo
        self.serviceRepository = serviceRepo
        self.scheduleRepository = scheduleRepo
        self.categoryRepository = categoryRepo

        // 3. Casos de Uso
        self.loginUseCase = LoginUseCase()
        self.registerUseCase = RegisterUseCase(userRepository: userRepo)
        self.getUserUseCase = GetUserUseCase(userRepository: userRepo)
        self.updateUserUseCase = UpdateUserUseCase(userRepository: userRepo)
        self.getProfessionalsUseCase = GetProfessionalsUseCase(repository: userRepo)
        self.searchProfessionalsUseCase = SearchProfessionalsUseCase(userRepository: userRepo)
        self.getChatsUseCase = GetChatsUseCase(repository: chatRepo)
        self.getMessagesUseCase = GetMessagesUseCase(repository: chatRepo)
        self.sendMessageUseCase = SendMessageUseCase(repository: chatRepo)
    }
}
