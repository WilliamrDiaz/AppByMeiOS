//
//  UpdateUserUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

struct UpdateUserUseCase {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func execute(user: User) async throws {
        try await userRepository.updateUser(user: user)
    }
}
