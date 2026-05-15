//
//  ProfessionalProfileView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI
import FirebaseAuth

struct ProfessionalProfileView: View {
    @StateObject private var viewModel = ProfessionalProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Callbacks de navegación
    var onNavigateToLogin: () -> Void
    var onNavigateToAbout: () -> Void
    var onNavigateToHome: () -> Void
    var onNavigateToMessages: () -> Void
    var onNavigateToCalendar: () -> Void
    
    // Estados para los diálogos (Modals)
    @State private var showAddServiceDialog = false
    @State private var showAddScheduleDialog = false
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.uiState.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        //  1. Foto de perfil con Badge de Edición 
                        profilePhotoSection
                        
                        //  2. Campos de Texto (Nombre, Apellido, Descripción) 
                        VStack(spacing: 12) {
                            customEditField(placeholder: "Nombre", text: Binding(
                                get: { viewModel.uiState.name },
                                set: { viewModel.onNameChange($0) }
                            ))
                            
                            customEditField(placeholder: "Apellido", text: Binding(
                                get: { viewModel.uiState.lastname },
                                set: { viewModel.onLastnameChange($0) }
                            ))
                            
                            customEditField(placeholder: "Descripción", text: Binding(
                                get: { viewModel.uiState.description },
                                set: { viewModel.onDescriptionChange($0) }
                            ), isLarge: true)
                        }
                        
                        //  3. Sección de Servicios 
                        sectionHeader(title: "Servicios", onAdd: { showAddServiceDialog = true })
                        servicesList
                        
                        //  4. Sección de Horarios 
                        sectionHeader(title: "Horarios", onAdd: { showAddScheduleDialog = true })
                        schedulesList
                        
                        //  5. Título Profesional (Upload Placeholder) 
                        professionalTitleSection
                        
                        //  6. Botones de Acción 
                        actionButtons
                        
                        Spacer(minLength: 32)
                    }
                    .padding(24)
                }
            }
            
            // Barra inferior (Misma que HomeScreen)
            HomeBottomBar(
                selectedTab: .profile,
                onHome: { onNavigateToHome() },
                onMessages: { onNavigateToMessages() },
                onCalendar: { onNavigateToCalendar() },
                onProfile: { }
            )
        }
        .navigationTitle("Mi Perfil Profesional")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: onNavigateToAbout) {
                        Label("Acerca de ByMe", systemImage: "info.circle")
                    }
                    Button(role: .destructive, action: {
                        try? Auth.auth().signOut()
                        onNavigateToHome()
                    }) {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                }
            }
        }
        //  Diálogos (Sheets) 
        .sheet(isPresented: $showAddServiceDialog) { addServiceSheet }
        .sheet(isPresented: $showAddScheduleDialog) { addScheduleSheet }
        .alert("Éxito", isPresented: $viewModel.uiState.isSuccess) {
            Button("OK") { viewModel.resetSuccess() }
        } message: {
            Text("Perfil actualizado correctamente")
        }
    }
    
    //  SUB-VISTAS
    
    private var profilePhotoSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                )
            
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 32, height: 32)
                .shadow(radius: 2)
                .overlay(
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                )
        }
    }
    
    private func customEditField(placeholder: String, text: Binding<String>, isLarge: Bool = false) -> some View {
        HStack(alignment: isLarge ? .top : .center) {
            if isLarge {
                TextEditor(text: text)
                    .frame(height: 120)
            } else {
                TextField(placeholder, text: text)
            }
            Spacer()
            Image(systemName: "pencil").foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
    }
    
    private func sectionHeader(title: String, onAdd: @escaping () -> Void) -> some View {
        HStack {
            Text(title).fontWeight(.medium).font(.system(size: 14)).foregroundColor(.blue)
            Spacer()
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill").foregroundColor(.blue).font(.title3)
            }
        }
    }
    
    private var servicesList: some View {
        VStack(spacing: 8) {
            if viewModel.uiState.services.isEmpty {
                Text("No hay servicios agregados").font(.caption).foregroundColor(.gray)
            } else {
                ForEach(Array(viewModel.uiState.services.enumerated()), id: \.offset) { index, service in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(service.name).bold().font(.system(size: 14))
                            Text(service.description).font(.system(size: 13)).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { viewModel.removeService(service) }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var schedulesList: some View {
        VStack(spacing: 8) {
            if viewModel.uiState.schedules.isEmpty {
                Text("No hay horarios agregados").font(.caption).foregroundColor(.gray)
            } else {
                ForEach(Array(viewModel.uiState.schedules.enumerated()), id: \.offset) { index, schedule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(schedule.day).bold().font(.system(size: 14))
                            ForEach(Array(schedule.hours.split(separator: "\n").enumerated()), id: \.offset) { hIndex, hour in
                                Text("• \(String(hour))").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(action: { viewModel.removeSchedule(schedule) }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var professionalTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título profesional").fontWeight(.medium).font(.system(size: 14)).foregroundColor(.blue)
            VStack {
                Image(systemName: "doc.badge.plus").font(.largeTitle).foregroundColor(.gray.opacity(0.4))
                Text("Subir archivo").font(.system(size: 14)).foregroundColor(.gray.opacity(0.4))
                Text("Próximamente").font(.system(size: 12)).foregroundColor(.gray.opacity(0.3))
            }
            .frame(maxWidth: .infinity).frame(height: 120)
            .background(Color(.systemGray6)).cornerRadius(12)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.saveProfile() }) {
                if viewModel.uiState.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Guardar Cambios")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.uiState.hasChanges && !viewModel.uiState.isSaving ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(24)
            .disabled(!viewModel.uiState.hasChanges || viewModel.uiState.isSaving)
            
            Button("Volver") { onNavigateToHome() }
                .frame(maxWidth: .infinity).frame(height: 50)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.blue))
        }
        .padding(.top, 8)
    }

    //  MODALS (Equivalente a Dialogs de Android) 
    
    private var addServiceSheet: some View {
        NavigationStack {
            Form {
                TextField("Nombre del servicio", text: $serviceName)
                TextField("Descripción", text: $serviceDescription)
            }
            .navigationTitle("Nuevo Servicio")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { showAddServiceDialog = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        viewModel.addService(name: serviceName, description: serviceDescription)
                        serviceName = ""; serviceDescription = ""
                        showAddServiceDialog = false
                    }
                }
            }
        }
    }

    private var addScheduleSheet: some View {
        NavigationStack {
            Form {
                Picker("Día", selection: Binding(get: { viewModel.uiState.selectedDay }, set: { viewModel.onDaySelected($0) })) {
                    Text("Seleccionar").tag("")
                    ForEach(viewModel.dayOptions, id: \.self) { Text($0).tag($0) }
                }
                Picker("Desde", selection: Binding(get: { viewModel.uiState.selectedStartTime }, set: { viewModel.onStartTimeSelected($0) })) {
                    Text("Seleccionar").tag("")
                    ForEach(viewModel.timeOptions, id: \.self) { Text($0).tag($0) }
                }
                Picker("Hasta", selection: Binding(get: { viewModel.uiState.selectedEndTime }, set: { viewModel.onEndTimeSelected($0) })) {
                    Text("Seleccionar").tag("")
                    ForEach(viewModel.timeOptions, id: \.self) { Text($0).tag($0) }
                }
            }
            .navigationTitle("Nuevo Horario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { showAddScheduleDialog = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agregar") {
                        viewModel.addSchedule()
                        showAddScheduleDialog = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfessionalProfileView(onNavigateToLogin: {}, onNavigateToAbout: {},
            onNavigateToHome: {},
            onNavigateToMessages: {},
            onNavigateToCalendar: {}
        )
    }
}
