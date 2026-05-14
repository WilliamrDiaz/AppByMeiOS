//
//  AppointmentRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol AppointmentRepositoryProtocol {
    func createAppointment(appointment: Appointment) async throws
    func getUserAppointments(userId: String) async throws -> [Appointment]
    func getProfessionalAppointments(professionalId: String) async throws -> [Appointment]
    func updateAppointmentStatus(appointmentId: String, status: String) async throws
}
