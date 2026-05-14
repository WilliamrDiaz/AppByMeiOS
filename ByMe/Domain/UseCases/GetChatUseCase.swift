//
//  GetChatUseCase.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct GetChatsUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String) -> AsyncStream<[Chat]> {
        return repository.getChats(userId: userId)
    }
}
