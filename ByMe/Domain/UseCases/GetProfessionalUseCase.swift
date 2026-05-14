//
//  GetProfessionalUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct GetProfessionalsUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // El equivalente al 'invoke' de Kotlin
    func execute() async throws -> [User] {
        return try await repository.getProfessionals()
    }
}
