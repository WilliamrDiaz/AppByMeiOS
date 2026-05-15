//
//  About.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI

struct AboutView: View {
    // Para cerrar la pantalla
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Encabezado
                VStack(spacing: 8) {
                    Text("ByMe")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Servicios a tu alrededor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Conectando personas con profesionales.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Text("Versión 1.0.0 (iOS)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Text("2026 - 1")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Divider().padding(.vertical, 10)
                
                // Card: Descripción
                AboutCard(title: "Descripción") {
                    Text("ByMe es una aplicación móvil que conecta usuarios con profesionales de servicios del hogar y educación. Permite encontrar plomeros, profesores, cuidadores y más, de forma rápida y confiable en tu área, facilitando la contratación de servicios de manera rápida y segura desde tu iPhone.")
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                // Card: Tecnologías
                AboutCard(title: "Tecnologías") {
                    VStack(alignment: .leading, spacing: 6) {
                        TechItem(name: "SwiftUI: Interfaz Declarativa.")
                        TechItem(name: "SwiftData: Persistencia Local.")
                        TechItem(name: "Firebase: Auth, Firestore, Storage.")
                        TechItem(name: "Google Sign-In")
                        TechItem(name: "Swift Concurrency Async/Await.")
                        TechItem(name: "SF Symbols Iconografía nativa.")
                    }
                }
                
                // Card: Créditos
                AboutCard(title: "Desarrollado por") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("William Rodrigo Diaz Maca").font(.subheadline)
                        Text("Carlos Santiago Balcazar Velasquez").font(.subheadline)
                    }
                }
                
                // Card: Información Académica
                AboutCard(title: "Información Académica") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Universidad del Cauca").font(.subheadline)
                        Text("Desarrollo de aplicaciones para dispositivos móviles").font(.subheadline)
                        Text("Docente: Cristhian Nicolas Figueroa Martinez").font(.subheadline)
                    }
                }
                
                Spacer(minLength: 32)
            }
            .padding(24)
        }
        .navigationTitle("Acerca de ByMe")
        .navigationBarTitleDisplayMode(.inline)        
    }
}

// Componentes Reutilizables

struct AboutCard<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TechItem: View {
    let name: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text(name)
                .font(.subheadline)
        }
    }
}

// --- Preview ---
#Preview {
    AboutView()
}
