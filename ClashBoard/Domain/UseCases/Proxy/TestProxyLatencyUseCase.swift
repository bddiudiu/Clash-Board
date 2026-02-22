//
//  TestProxyLatencyUseCase.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class TestProxyLatencyUseCase {

    // MARK: - Properties

    private let repository: ProxyRepositoryProtocol
    private let defaultURL = "http://www.gstatic.com/generate_204"
    private let defaultTimeout = 5000

    // MARK: - Initialization

    init(repository: ProxyRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution

    func execute(proxyName: String, url: String? = nil, timeout: Int? = nil) async throws -> Int {
        return try await repository.testLatency(
            proxyName: proxyName,
            url: url ?? defaultURL,
            timeout: timeout ?? defaultTimeout
        )
    }
}
