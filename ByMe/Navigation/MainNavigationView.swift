//
//  MainNavigationView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct MainNavigationView: View {
    // Esta es nuestra "pila" de navegación (el Backstack)
    @State private var path = [AppRoute.splash]
    
    var body: some View {
        NavigationStack(path: $path) {
            // No ponemos nada aquí, todo se maneja en navigationDestination
            Color.clear
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .splash:
                        SplashView(onNavigateToHome: {
                            // popUpTo SPLASH inclusive = path.removeAll y añadir home
                            path = [.home]
                        })
                        .navigationBarHidden(true)

                    case .login:
                        LoginView(
                            onNavigateToHome: { path = [.home] },
                            onNavigateToRegister: { path.append(.register) }
                        )

                    case .register:
                        RegisterView(
                            onNavigateToHome: { path = [.home] },
                            onNavigateToLogin: { path = [.login] }
                        )

                    case .home:
                        HomeView(
                            onNavigateToLogin: { path.append(.login) },
                            onNavigateToProfessionalDetail: { id in
                                path.append(.professionalDetail(professionalId: id))
                            },
                            onNavigateToProfile: { path.append(.userProfile) },
                            onNavigateToMessages: { path.append(.chatList) },
                            onNavigateToCalendar: { path.append(.calendar) }
                        )

                    case .professionalDetail(let id):
                        ProfessionalDetailView(
                            professionalId: id,
                            onNavigateBack: { path.removeLast() },
                            onNavigateToLogin: { path.append(.login) },
                            onNavigateToChat: {chatId, name in
                                path.append(.chatDetail(chatId: chatId, professionalName: name))
                            },
                            onNavigateToProfile : { path.append(.userProfile) },
                            onNavigateToMessages: { path.append(.chatList) },
                            onNavigateToCalendar: { path.append(.calendar) },
                            onNavigateToHome: { path = [.home] }
                        )

                    case .chatList:
                        ChatListView(
                            onNavigateToChat: { chatId, name in
                                path.append(.chatDetail(chatId: chatId, professionalName: name))
                            },
                            onNavigateToLogin: { path.append(.login) },
                            onNavigateToProfile: { path.append(.userProfile) },
                            onNavigateToCalendar: { path.append(.calendar) },
                            onNavigateToHome: { path = [.home] }
                        )

                        case .chatDetail(let id, let name):
                            ChatDetailView(chatId: id, professionalName: name, onNavigateBack: { path.removeLast() }
                            )

                    case .userProfile:
                        UserProfileRouterView(path: $path)

                    /*case .offerService:
                        OfferServiceView(onSaveSuccess: {
                            path = [.home]
                        })
                     */

                    case .about:
                        AboutView()
                        
                    default:
                        Text("Pantalla en construcción")
                    }
                }
        }
    }
}

// Vista auxiliar para manejar la lógica de perfil (Profesional - Usuario)
struct UserProfileRouterView: View {
    @Binding var path: [AppRoute]
    // Inyectamos el ViewModel
    @StateObject private var viewModel = UserTypeViewModel()
    
    var body: some View {
        if Auth.auth().currentUser == nil {
            VStack {
                ProgressView()
            }
            .onAppear {
                path.append(.login)
            }
        } else if viewModel.isProfessional == nil {
            ProgressView("Verificando perfil...")
        } else if viewModel.isProfessional == true {
            ProfessionalProfileView(
                onNavigateToLogin: { path.append(.login) },
                onNavigateToAbout: { path.append(.about) },
                onNavigateToHome: { path = [.home]},
                onNavigateToMessages: { path.append(.chatList) },
                onNavigateToCalendar: { path.append(.calendar) }
            )
            
        } else {
            ProfileView(
                onNavigateToLogin: { path.append(.login) },
                onNavigateToProfessionalProfile: { path.append(.offerService) },
                onNavigateToAbout: { path.append(.about) },
                onNavigateToMessages: { path.append(.chatList) },
                onNavigateToCalendar: { path.append(.calendar) },
                onNavigateToHome: { path = [.home] }
            )
        }
    }
}
