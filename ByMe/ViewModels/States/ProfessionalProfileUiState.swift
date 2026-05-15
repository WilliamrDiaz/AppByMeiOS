//
//  ProfessionalProfileUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct ProfessionalProfileUiState {
    var isLoading: Bool = false
    var isSaving: Bool = false
    var isSuccess: Bool = false
    var user: User? = nil
    var name: String = ""
    var lastname: String = ""
    var description: String = ""
    var services: [Service] = []
    var schedules: [Schedule] = []
    var selectedDay: String = ""
    var selectedStartTime: String = ""
    var selectedEndTime: String = ""
    var errorMessage: String? = nil
    var hasChanges: Bool = false
}
