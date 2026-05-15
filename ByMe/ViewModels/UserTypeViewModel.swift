//
//  UserTypeViewModel.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class UserTypeViewModel: ObservableObject {
    @Published var isProfessional: Bool? = nil
    private let userRepository = DependencyContainer.shared.userRepository

    init() {
        checkUserType()
    }

    func checkUserType() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.isProfessional = false
            return
        }

        Task {
            do {
                let user = try await userRepository?.getUser(userId: userId)
                self.isProfessional = user?.isProfessional
            } catch {
                print("Error verificando tipo de usuario: \(error)")
                self.isProfessional = false
            }
        }
    }
}
