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
    private let modelContext: ModelContext
    let userLocalDataSource: UserLocalDataSource
    
    // Repositories
    let userRepository: UserRepositoryProtocol
    let chatRepository: ChatRepositoryProtocol
    let reviewRepository: ReviewRepositoryProtocol
    let appointmentRepository: AppointmentRepositoryProtocol
    let serviceRepository: ServiceRepositoryProtocol
    let scheduleRepository: ScheduleRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    
    // Use Cases
    let loginUseCase: LoginUseCase
    let registerUseCase: RegisterUseCase
    let getUserUseCase: GetUserUseCase
    let updateUserUseCase: UpdateUserUseCase
    let getProfessionalsUseCase: GetProfessionalsUseCase
    let searchProfessionalsUseCase: SearchProfessionalsUseCase
    let getChatsUseCase: GetChatsUseCase
    let getMessagesUseCase: GetMessagesUseCase
    let sendMessageUseCase: SendMessageUseCase

    private init() {
        // 1. Inicializar SwiftData (Base de datos local)
        do {
            let container = try ModelContainer(for: UserEntity.self)
            self.modelContext = container.mainContext
        } catch {
            fatalError("No se pudo inicializar SwiftData: \(error)")
        }
        
        // 2. Inicializar Data Source Local
        self.userLocalDataSource = UserLocalDataSource(modelContext: modelContext)
        
        // 3. Inicializar Repositorios (Capa de Datos)
        self.userRepository = UserRepositoryImpl(localDataSource: userLocalDataSource)
        self.chatRepository = ChatRepositoryImpl()
        self.reviewRepository = ReviewRepositoryImpl()
        self.appointmentRepository = AppointmentRepositoryImpl()
        self.serviceRepository = ServiceRepositoryImpl()
        self.scheduleRepository = ScheduleRepositoryImpl()
        self.categoryRepository = CategoryRepositoryImpl()
        
        // 4. Inicializar Casos de Uso (Capa de Dominio)
        self.loginUseCase = LoginUseCase()
        self.registerUseCase = RegisterUseCase(userRepository: userRepository)
        self.getUserUseCase = GetUserUseCase(userRepository: userRepository)
        self.updateUserUseCase = UpdateUserUseCase(userRepository: userRepository)
        self.getProfessionalsUseCase = GetProfessionalsUseCase(repository: userRepository)
        self.searchProfessionalsUseCase = SearchProfessionalsUseCase(userRepository: userRepository)
        self.getChatsUseCase = GetChatsUseCase(repository: chatRepository)
        self.getMessagesUseCase = GetMessagesUseCase(repository: chatRepository)
        self.sendMessageUseCase = SendMessageUseCase(repository: chatRepository)
    }
}
