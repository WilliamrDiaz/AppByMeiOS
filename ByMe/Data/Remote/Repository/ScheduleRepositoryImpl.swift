//
//  ScheduleRepositoryImpl.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//
import Foundation
import FirebaseFirestore

class ScheduleRepositoryImpl: ScheduleRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func getSchedules(userId: String) async throws -> [Schedule] {
        let snapshot = try await db.collection("users").document(userId).collection("schedules").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Schedule.self) }
    }

    func addSchedule(userId: String, schedule: Schedule) async throws {
        try db.collection("users").document(userId).collection("schedules").addDocument(from: schedule)
    }

    func deleteSchedule(userId: String, scheduleId: String) async throws {
        try await db.collection("users").document(userId).collection("schedules").document(scheduleId).delete()
    }
}
