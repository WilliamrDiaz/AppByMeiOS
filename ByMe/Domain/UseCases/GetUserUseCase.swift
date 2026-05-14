//
//  GetUserUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

struct GetUserUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute(userId: String) async throws -> User {
        return try await userRepository.getUser(userId: userId)
    }
}
