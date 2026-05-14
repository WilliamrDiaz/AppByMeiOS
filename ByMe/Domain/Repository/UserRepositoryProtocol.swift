//
//  UserRepositoryInterface.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol UserRepositoryProtocol {
    func createUser(user: User) async throws
    func getUser(userId: String) async throws -> User
    func updateUser(user: User) async throws
    func getProfessionals() async throws -> [User]
    func searchProfessionals(query: String) async throws -> [User]
}
