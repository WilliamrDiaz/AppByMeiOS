//
//  ChatDetailUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct ChatDetailUiState {
    var chatId: String = ""
    var professionalName: String = ""
    var messageText: String = ""
    var messages: [Message] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
