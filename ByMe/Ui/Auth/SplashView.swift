//
//  SplashView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI

struct SplashView: View {
    @State private var startAnimation = false
    var onNavigateToHome: () -> Void
    
    var body: some View {
        ZStack {
            // Fondo color primario
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text("ByMe")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Servicios a tu alrededor.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .opacity(startAnimation ? 1 : 0) // Animación de opacidad
        }
        .onAppear {
            // Animación de entrada
            withAnimation(.easeIn(duration: 1.0)) {
                startAnimation = true
            }
            
            // Delay de 2 segundos antes de navegar
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onNavigateToHome()
            }
        }
    }
}

#Preview {
    SplashView(onNavigateToHome: {
        print("Navegando a Home...")
    })
}
