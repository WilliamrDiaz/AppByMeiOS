//
//  SendMessageUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

struct SendMessageUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(chatId: String, message: Message) async throws {
        try await repository.sendMessage(chatId: chatId, message: message)
    }
}
