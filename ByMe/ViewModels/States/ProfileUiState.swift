//
//  ProfileUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct ProfileUiState {
    var isLoading: Bool = false
    var isSaving: Bool = false
    var isSuccess: Bool = false
    var user: User? = nil
    var name: String = ""
    var lastname: String = ""
    var phone: String = ""
    var errorMessage: String? = nil
}
