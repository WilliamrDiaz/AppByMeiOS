//
//  ProfessionalDetailUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct ProfessionalDetailUiState {
    var isLoading: Bool = false
    var professional: User? = nil
    var reviews: [Review] = []
    var services: [Service] = []
    var schedules: [Schedule] = []
    var errorMessage: String? = nil
    var selectedTab: Int = 0
}
