//
//  ServiceRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol ServiceRepositoryProtocol {
    func getServices(userId: String) async throws -> [Service]
    func addService(userId: String, service: Service) async throws
    func deleteService(userId: String, serviceId: String) async throws
}
