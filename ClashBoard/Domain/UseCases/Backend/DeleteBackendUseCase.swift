//
//  DeleteBackendUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class DeleteBackendUseCase {

    // MARK: - Properties

    private let repository: BackendRepositoryProtocol

    // MARK: - Initialization

    init(repository: BackendRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(backendId: UUID) async throws {
        try await repository.deleteBackend(backendId)
    }
}
