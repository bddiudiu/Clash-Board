//
//  BackendRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

protocol BackendRepositoryProtocol {
    func fetchBackends() async throws -> [Backend]
    func addBackend(_ backend: Backend) async throws
    func updateBackend(_ backend: Backend) async throws
    func deleteBackend(_ backendId: UUID) async throws
    func getActiveBackend() async throws -> Backend?
    func setActiveBackend(_ backendId: UUID) async throws
    func testBackend(_ backend: Backend) async throws -> Bool
}
