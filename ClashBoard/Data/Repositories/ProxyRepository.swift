//
//  ProxyRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class ProxyRepository: ProxyRepositoryProtocol {

    // MARK: - Properties

    private let remoteDataSource: ProxyRemoteDataSource
    private let webSocketManager: WebSocketManagerProtocol

    private let proxySubject = CurrentValueSubject<[ProxyGroup], Never>([])

    var proxyUpdates: AnyPublisher<[ProxyGroup], Never> {
        proxySubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        remoteDataSource: ProxyRemoteDataSource,
        webSocketManager: WebSocketManagerProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.webSocketManager = webSocketManager
    }

    // MARK: - Public Methods

    func fetchProxies() async throws -> [ProxyGroup] {
        let proxies = try await remoteDataSource.fetchProxies()
        proxySubject.send(proxies)
        return proxies
    }

    func selectProxy(groupName: String, proxyName: String) async throws {
        try await remoteDataSource.selectProxy(groupName: groupName, proxyName: proxyName)

        // 更新本地状态
        var currentProxies = proxySubject.value
        if let index = currentProxies.firstIndex(where: { $0.name == groupName }) {
            currentProxies[index] = ProxyGroup(
                id: currentProxies[index].id,
                name: currentProxies[index].name,
                type: currentProxies[index].type,
                now: proxyName,
                all: currentProxies[index].all,
                proxies: currentProxies[index].proxies
            )
            proxySubject.send(currentProxies)
        }
    }

    func testLatency(proxyName: String, url: String, timeout: Int) async throws -> Int {
        return try await remoteDataSource.testLatency(proxyName: proxyName, url: url, timeout: timeout)
    }

    func updateProvider(name: String) async throws {
        try await remoteDataSource.updateProvider(name: name)
    }

    func healthCheckProvider(name: String) async throws {
        try await remoteDataSource.healthCheckProvider(name: name)
    }
}
