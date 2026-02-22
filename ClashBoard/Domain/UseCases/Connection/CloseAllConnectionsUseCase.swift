//
//  CloseAllConnectionsUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class CloseAllConnectionsUseCase {

    // MARK: - Properties

    private let repository: ConnectionRepositoryProtocol

    // MARK: - Initialization

    init(repository: ConnectionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute() async throws {
        try await repository.closeAllConnections()
    }
}
