//
//  SelectProxyUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class SelectProxyUseCase {

    // MARK: - Properties

    private let repository: ProxyRepositoryProtocol

    // MARK: - Initialization

    init(repository: ProxyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(groupName: String, proxyName: String) async throws {
        try await repository.selectProxy(groupName: groupName, proxyName: proxyName)
    }
}
