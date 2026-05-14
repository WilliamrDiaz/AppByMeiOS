//
//  LoginUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseAuth

struct LoginUseCase {
    // Usamos el singleton Auth.auth() por defecto o inyectado
    private let auth = Auth.auth()

    func execute(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
}
