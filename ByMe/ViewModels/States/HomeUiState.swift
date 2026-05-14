//
//  HomeUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct HomeUiState {
    var isLoading: Bool = false
    var professionals: [User] = []
    var errorMessage: String? = nil
    var searchQuery: String = ""
}
