//
//  SearchProfessionalasUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

struct SearchProfessionalsUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute(query: String) async throws -> [User] {
        return try await userRepository.searchProfessionals(query: query)
    }
}
