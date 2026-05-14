//
//  CategoryRepositoryProtocol.swift
//  ByMe
//
//  Created by william diaz on 14/05/26.
//

protocol CategoryRepositoryProtocol {
    func getCategories() async throws -> [Category]
}
