//
//  OfferServiceView.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import SwiftUI

struct OfferServiceView: View {
    @StateObject private var viewModel = OfferServiceViewModel()
    @Environment(\.dismiss) var dismiss
    
    var onNavigateBack: () -> Void
    var onSaveSuccess: () -> Void
    
    @State private var showAddServiceDialog = false
    @State private var showAddScheduleDialog = false
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    
    let experienceOptions = ["1 a 4 años", "4 a 8 años", "8 o más años"]

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.uiState.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 1. Categoría
                            sectionLabel("¿En qué categoría eres experto?")
                            Menu {
                                ForEach(viewModel.uiState.categories) { cat in
                                    Button(cat.name) { viewModel.onCategorySelected(cat.name) }
                                }
                            } label: {
                                dropdownField(value: viewModel.uiState.selectedCategory, placeholder: "Selecciona una categoría")
                            }

                            //  2. Experiencia 
                            sectionLabel("¿Cuánta experiencia tienes?")
                            Menu {
                                ForEach(experienceOptions, id: \.self) { opt in
                                    Button(opt) { viewModel.onExperienceSelected(opt) }
                                }
                            } label: {
                                dropdownField(value: viewModel.uiState.selectedExperience, placeholder: "Selecciona tu experiencia")
                            }

                            //  3. Descripción 
                            sectionLabel("Descripción de tu perfil")
                            TextEditor(text: Binding(get: { viewModel.uiState.description }, set: { viewModel.onDescriptionChange($0) }))
                                .frame(height: 120)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))

                            //  4. Servicios 
                            HStack {
                                sectionLabel("Tus servicios")
                                Spacer()
                                Button(action: { showAddServiceDialog = true }) {
                                    Image(systemName: "plus.circle.fill").font(.title3)
                                }
                            }
                            servicesList

                            //  5. Horarios 
                            HStack {
                                sectionLabel("Tus horarios de atención")
                                Spacer()
                                Button(action: { showAddScheduleDialog = true }) {
                                    Image(systemName: "plus.circle.fill").font(.title3)
                                }
                            }
                            schedulesList

                            //  6. Título (Placeholder) 
                            sectionLabel("Sube tu título profesional")
                            uploadPlaceholder

                            Spacer(minLength: 32)

                            //  7. Botones 
                            HStack(spacing: 12) {
                                Button(action: { viewModel.saveProfile() }) {
                                    Group {
                                        if viewModel.uiState.isSaving { ProgressView().tint(.white) }
                                        else { Text("Guardar").fontWeight(.bold) }
                                    }
                                    .frame(maxWidth: .infinity).frame(height: 50)
                                    .background(Color.blue).foregroundColor(.white).cornerRadius(24)
                                }.disabled(viewModel.uiState.isSaving)

                                Button("Volver") { onNavigateBack() }
                                    .frame(maxWidth: .infinity).frame(height: 50)
                                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.blue))
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Ofrecer Servicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onNavigateBack) { Image(systemName: "arrow.left").foregroundColor(.primary) }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) { Image(systemName: "ellipsis").rotationEffect(.degrees(90)).foregroundColor(.primary) }
                }
            }
            .sheet(isPresented: $showAddServiceDialog) { addServiceSheet }
            .sheet(isPresented: $showAddScheduleDialog) { addScheduleSheet }
            .onChange(of: viewModel.uiState.isSuccess) { oldValue, newValue in
                if newValue { onSaveSuccess() }
            }
        }
    }

    //  Helpers de UI 

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 14, weight: .medium)).foregroundColor(.blue)
    }

    private func dropdownField(value: String, placeholder: String) -> some View {
        HStack {
            Text(value.isEmpty ? placeholder : value)
                .foregroundColor(value.isEmpty ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down").font(.caption).foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))
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
                        Button(action: { viewModel.removeService(at: index) }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        }
                    }
                    .padding(12).background(Color(.systemGray6)).cornerRadius(12)
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
                            ForEach(schedule.hours.split(separator: "\n"), id: \.self) { hour in
                                Text("• \(String(hour))").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button(action: { viewModel.removeSchedule(at: index) }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                        }
                    }
                    .padding(12).background(Color(.systemGray6)).cornerRadius(12)
                }
            }
        }
    }

    private var uploadPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "paperclip").font(.largeTitle).foregroundColor(.gray.opacity(0.4))
            Text("Subir archivo").font(.system(size: 14)).foregroundColor(.gray.opacity(0.4))
            Text("Próximamente").font(.system(size: 12)).foregroundColor(.gray.opacity(0.3))
        }
        .frame(maxWidth: .infinity).frame(height: 120)
        .background(Color(.systemGray6)).cornerRadius(12)
    }

    //  Sheets 
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
