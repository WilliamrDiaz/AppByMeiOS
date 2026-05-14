//
//  AppRoute.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation

// Hashable es necesario para que SwiftUI pueda identificar cada ruta
enum AppRoute: Hashable {
    case splash
    case login
    case register
    case home
    case searchResults
    case professionalDetail(professionalId: String) 
    case chatList
    case chatDetail(chatId: String, professionalName: String)
    case calendar
    case userProfile
    case professionalProfile
    case offerService
    case about
}
