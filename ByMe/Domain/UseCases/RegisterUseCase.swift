//
//  RegisterUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseAuth

struct RegisterUseCase {
    private let userRepository: UserRepositoryProtocol
    private let auth = Auth.auth()

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute(name: String, lastname: String, email: String, phone: String, password: String) async throws {
        // 1. Crear usuario en Firebase Auth
        let result = try await auth.createUser(withEmail: email, password: password)
        let userId = result.user.uid
        
        // 2. Crear el objeto User para Firestore
        let user = User(
            id: userId,
            name: name,
            lastname: lastname,
            email: email,
            phone: phone,
            isProfessional: false,
            role: "user"
        )
        
        // 3. Guardar en el repositorio
        try await userRepository.createUser(user: user)
    }
}
