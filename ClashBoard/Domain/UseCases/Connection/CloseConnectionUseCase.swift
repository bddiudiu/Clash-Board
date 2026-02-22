//
//  CloseConnectionUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class CloseConnectionUseCase {

    // MARK: - Properties

    private let repository: ConnectionRepositoryProtocol

    // MARK: - Initialization

    init(repository: ConnectionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(connectionId: String) async throws {
        try await repository.closeConnection(id: connectionId)
    }
}
