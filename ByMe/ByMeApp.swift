//
//  ByMeApp.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct ByMeApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            //ContentView()
            MainNavigationViewWrapper()
        }
        .modelContainer(for: UserEntity.self) // Esto inicializa la base de datos local
    }
}

struct MainNavigationViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        MainNavigationView()
            .onAppear {
                DependencyContainer.configure(modelContext: modelContext)
            }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

