//
//  ChatListUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct ChatListUiState {
    var isLoading: Bool = false
    var chats: [Chat] = []
    var drafts: [String: String] = [:]
    var pendingChats: [Chat] = []
    var errorMessage: String? = nil
}
