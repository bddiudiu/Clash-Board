//
//  ProxyListViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class ProxyListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var proxyGroups: [ProxyGroup] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var testingGroups: Set<String> = []

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let apiClient: APIClientProtocol

    // MARK: - Initialization

    init(apiClient: APIClientProtocol? = nil) {
        self.apiClient = apiClient ?? DIContainer.shared.resolve(APIClientProtocol.self)
    }

    // MARK: - Public Methods

    @MainActor
    func fetchProxies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: ProxiesResponse = try await apiClient.request(.getProxies)
            proxyGroups = parseProxyGroups(from: response)
        } catch {
            self.error = error
        }
    }

    func selectProxy(group: String, proxy: String) {
        Task { @MainActor in
            do {
                let _: EmptyResponse = try await apiClient.request(.selectProxy(group: group, name: proxy))

                // 更新本地状态
                if let index = proxyGroups.firstIndex(where: { $0.name == group }) {
                    var updatedGroup = proxyGroups[index]
                    updatedGroup = ProxyGroup(
                        id: updatedGroup.id,
                        name: updatedGroup.name,
                        type: updatedGroup.type,
                        now: proxy,
                        all: updatedGroup.all,
                        proxies: updatedGroup.proxies
                    )
                    proxyGroups[index] = updatedGroup
                }
            } catch {
                self.error = error
            }
        }
    }

    func testLatency(proxyName: String) {
        Task {
            await testSingleLatency(proxyName: proxyName)
        }
    }

    func testAllLatency() {
        for group in proxyGroups {
            testGroupLatency(groupName: group.name)
        }
    }

    func testGroupLatency(groupName: String) {
        guard let group = proxyGroups.first(where: { $0.name == groupName }) else { return }

        Task { @MainActor in
            testingGroups.insert(groupName)
            await withTaskGroup(of: Void.self) { taskGroup in
                for proxy in group.proxies {
                    taskGroup.addTask { [weak self] in
                        await self?.testSingleLatency(proxyName: proxy.name)
                    }
                }
            }
            testingGroups.remove(groupName)
        }
    }

    func clearError() {
        error = nil
    }

    // MARK: - Private Methods

    private func testSingleLatency(proxyName: String) async {
        let defaults = UserDefaults.standard
        let url = defaults.string(forKey: "speedtestURL") ?? "http://www.gstatic.com/generate_204"
        let timeout = defaults.object(forKey: "speedtestTimeout") as? Int ?? 5000

        do {
            let response: DelayResponse = try await apiClient.request(
                .getProxyDelay(
                    name: proxyName,
                    url: url,
                    timeout: timeout
                )
            )
            await MainActor.run {
                updateProxyLatency(name: proxyName, delay: response.delay)
            }
        } catch {
            await MainActor.run {
                updateProxyLatency(name: proxyName, delay: nil)
            }
        }
    }

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
                    latency: latency.flatMap { $0 > 0 ? $0 : nil }
                )
            }

            let group = ProxyGroup(
                name: name,
                type: ProxyGroupType(rawValue: proxyData.type) ?? .selector,
                now: proxyData.now,
                all: all,
                proxies: sortProxiesByLatency(proxies)
            )
            groups.append(group)
        }

        return groups.sorted { $0.name < $1.name }
    }

    private func updateProxyLatency(name: String, delay: Int?) {
        for (groupIndex, group) in proxyGroups.enumerated() {
            if let proxyIndex = group.proxies.firstIndex(where: { $0.name == name }) {
                let oldProxy = proxyGroups[groupIndex].proxies[proxyIndex]
                let updatedProxy = Proxy(
                    id: oldProxy.id,
                    name: oldProxy.name,
                    type: oldProxy.type,
                    latency: delay.flatMap { $0 > 0 ? $0 : nil }
                )
                var updatedProxies = proxyGroups[groupIndex].proxies
                updatedProxies[proxyIndex] = updatedProxy
                proxyGroups[groupIndex] = ProxyGroup(
                    id: group.id,
                    name: group.name,
                    type: group.type,
                    now: group.now,
                    all: group.all,
                    proxies: sortProxiesByLatency(updatedProxies)
                )
            }
        }
    }

    private func sortProxiesByLatency(_ proxies: [Proxy]) -> [Proxy] {
        proxies.sorted { lhs, rhs in
            switch (lhs.latency, rhs.latency) {
            case let (left?, right?):
                if left != right {
                    return left < right
                }
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                break
            }

            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}

// MARK: - API Response Types

struct ProxiesResponse: Decodable {
    let proxies: [String: ProxyData]
}

struct ProxyData: Decodable {
    let name: String
    let type: String
    let now: String?
    let all: [String]?
    let history: [ProxyHistoryData]
}

struct ProxyHistoryData: Decodable {
    let time: String
    let delay: Int
}

struct DelayResponse: Decodable {
    let delay: Int
}

struct EmptyResponse: Decodable {}
