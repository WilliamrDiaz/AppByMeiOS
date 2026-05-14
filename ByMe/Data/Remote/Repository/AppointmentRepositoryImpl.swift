//
//  AppointmentRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

import Foundation
import FirebaseFirestore

class AppointmentRepositoryImpl: AppointmentRepositoryProtocol {
    private let db = Firestore.firestore()
    private let appointmentsCollection = "appointments"

    func createAppointment(appointment: Appointment) async throws {
        // Firestore convierte el objeto automáticamente si es Codable
        try db.collection(appointmentsCollection).addDocument(from: appointment)
    }

    func getUserAppointments(userId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(appointmentsCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Appointment.self)
        }
    }

    func getProfessionalAppointments(professionalId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(appointmentsCollection)
            .whereField("professionalId", isEqualTo: professionalId)
            .getDocuments()
            
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Appointment.self)
        }
    }

    func updateAppointmentStatus(appointmentId: String, status: String) async throws {
        try await db.collection(appointmentsCollection).document(appointmentId)
            .updateData(["status": status])
    }
}
