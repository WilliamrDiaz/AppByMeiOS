//
//  ScheduleRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol ScheduleRepositoryProtocol {
    func getSchedules(userId: String) async throws -> [Schedule]
    func addSchedule(userId: String, schedule: Schedule) async throws
    func deleteSchedule(userId: String, scheduleId: String) async throws
}
