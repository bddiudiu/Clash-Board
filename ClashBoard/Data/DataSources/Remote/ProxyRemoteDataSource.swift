//
//  ProxyRemoteDataSource.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class ProxyRemoteDataSource {

    // MARK: - Properties

    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func fetchProxies() async throws -> [ProxyGroup] {
        let response: ProxiesResponse = try await apiClient.request(.getProxies)
        return parseProxyGroups(from: response)
    }

    func selectProxy(groupName: String, proxyName: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.selectProxy(group: groupName, name: proxyName))
    }

    func testLatency(proxyName: String, url: String, timeout: Int) async throws -> Int {
        let response: DelayResponse = try await apiClient.request(
            .getProxyDelay(name: proxyName, url: url, timeout: timeout)
        )
        return response.delay
    }

    func updateProvider(name: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.updateProxyProvider(name: name))
    }

    func healthCheckProvider(name: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.healthCheckProxyProvider(name: name))
    }

    // MARK: - Private Methods

    private func parseProxyGroups(from response: ProxiesResponse) -> [ProxyGroup] {
        var groups: [ProxyGroup] = []

        for (name, proxyData) in response.proxies {
            guard let all = proxyData.all, !all.isEmpty else { continue }

            let proxies = all.compactMap { proxyName -> Proxy? in
                guard let proxy = response.proxies[proxyName] else { return nil }
                let latency = proxy.history.last?.delay
                return Proxy(
                    name: proxyName,
                    type: ProxyType(rawValue: proxy.type) ?? .direct,
                    latency: latency.flatMap { $0 > 0 ? $0 : nil },
                    history: proxy.history.map { LatencyHistory(time: Date(), delay: $0.delay) }
                )
            }

            let group = ProxyGroup(
                name: name,
                type: ProxyGroupType(rawValue: proxyData.type) ?? .selector,
                now: proxyData.now,
                all: all,
                proxies: proxies
            )
            groups.append(group)
        }

        return groups.sorted { $0.name < $1.name }
    }
}
