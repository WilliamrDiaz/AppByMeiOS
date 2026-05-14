//
//  GetMessagesUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct GetMessagesUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(chatId: String) -> AsyncStream<[Message]> {
        return repository.getMessages(chatId: chatId)
    }
}
