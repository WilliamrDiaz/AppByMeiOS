//
//  OfferServiceUiState.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

struct OfferServiceUiState {
    var isLoading: Bool = false
    var isSaving: Bool = false
    var isSuccess: Bool = false
    var categories: [Category] = []
    var selectedCategory: String = ""
    var selectedExperience: String = ""
    var description: String = ""
    var services: [Service] = []
    var schedules: [Schedule] = []
    var selectedDay: String = ""
    var selectedStartTime: String = ""
    var selectedEndTime: String = ""
    var errorMessage: String? = nil
}
