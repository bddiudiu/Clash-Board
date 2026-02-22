//
//  ConnectionListViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

enum ConnectionSortOrder: String, CaseIterable {
    case speed
    case traffic
    case time
    case host

    var displayName: String {
        switch self {
        case .speed: return "速度"
        case .traffic: return "流量"
        case .time: return "时间"
        case .host: return "主机"
        }
    }
}

final class ConnectionListViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var connections: [Connection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var sortBy: ConnectionSortOrder = .time {
        didSet { sortConnections() }
    }

    // MARK: - Private Properties

    private var previousConnections: [String: Connection] = [:]
    private var rawConnections: [Connection] = []
    private var cancellables = Set<AnyCancellable>()
    private let apiClient: APIClientProtocol
    private let webSocketManager: WebSocketManagerProtocol
    private var refreshTimer: Timer?

    // MARK: - Initialization

    init(
        apiClient: APIClientProtocol? = nil,
        webSocketManager: WebSocketManagerProtocol? = nil
    ) {
        self.apiClient = apiClient ?? DIContainer.shared.resolve(APIClientProtocol.self)
        self.webSocketManager = webSocketManager ?? DIContainer.shared.resolve(WebSocketManagerProtocol.self)
    }

    // MARK: - Public Methods

    func startMonitoring() {
        fetchConnections()

        // 定时刷新连接列表（每 2 秒）
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.fetchConnections()
        }
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        cancellables.removeAll()
    }

    func closeConnection(id: String) {
        Task { @MainActor in
            do {
                _ = try await apiClient.requestRaw(.closeConnection(id: id))
                connections.removeAll { $0.id == id }
                rawConnections.removeAll { $0.id == id }
                previousConnections.removeValue(forKey: id)
            } catch {
                self.error = error
            }
        }
    }

    func closeAllConnections() {
        Task { @MainActor in
            do {
                _ = try await apiClient.requestRaw(.closeAllConnections)
                connections.removeAll()
                rawConnections.removeAll()
                previousConnections.removeAll()
            } catch {
                self.error = error
            }
        }
    }

    // MARK: - Private Methods

    private func fetchConnections() {
        Task { @MainActor in
            do {
                let data = try await apiClient.requestRaw(.getConnections)
                let decoder = JSONDecoder()
                let response = try decoder.decode(ConnectionsResponse.self, from: data)

                // 计算速度：对比上一次的 upload/download 差值
                var updated = response.connections
                for i in updated.indices {
                    let conn = updated[i]
                    if let prev = previousConnections[conn.id] {
                        updated[i].uploadSpeed = max(0, (conn.upload - prev.upload) / 2)
                        updated[i].downloadSpeed = max(0, (conn.download - prev.download) / 2)
                    }
                }

                // 更新上次快照
                previousConnections = Dictionary(uniqueKeysWithValues: response.connections.map { ($0.id, $0) })

                rawConnections = updated
                sortConnections()
            } catch {
                // 静默处理，避免频繁报错
            }
        }
    }

    private func sortConnections() {
        switch sortBy {
        case .speed:
            connections = rawConnections.sorted { ($0.downloadSpeed + $0.uploadSpeed) > ($1.downloadSpeed + $1.uploadSpeed) }
        case .traffic:
            connections = rawConnections.sorted { $0.totalTraffic > $1.totalTraffic }
        case .time:
            connections = rawConnections.sorted { $0.start > $1.start }
        case .host:
            connections = rawConnections.sorted { $0.metadata.displayHost < $1.metadata.displayHost }
        }
    }
}
