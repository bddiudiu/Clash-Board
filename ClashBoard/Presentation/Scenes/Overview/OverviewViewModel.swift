//
//  OverviewViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class OverviewViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var uploadSpeed: Int64 = 0
    @Published private(set) var downloadSpeed: Int64 = 0
    @Published private(set) var totalUpload: Int64 = 0
    @Published private(set) var totalDownload: Int64 = 0
    @Published private(set) var activeConnections: Int = 0
    @Published private(set) var memoryUsage: Int64 = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var uploadHistory: [Int64] = []
    @Published private(set) var downloadHistory: [Int64] = []

    private let maxHistoryCount = 60

    // MARK: - Private Properties

    private var trafficTask: URLSessionWebSocketTask?
    private var memoryTask: URLSessionWebSocketTask?
    private var connectionsTimer: Timer?
    private let session = URLSession.shared

    // MARK: - Public Methods

    func startMonitoring() {
        let storage = UserDefaultsStorage()
        guard let backends = storage.load([Backend].self, for: StorageKey.backends),
              let activeId = storage.load(UUID.self, for: StorageKey.activeBackendId),
              let backend = backends.first(where: { $0.id == activeId }) else {
            return
        }

        // 确保 API 客户端已配置
        if let url = backend.baseURL {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            apiClient.configure(baseURL: url, secret: backend.secret)
        }

        connectTraffic(backend: backend)
        connectMemory(backend: backend)
        startConnectionsPolling(backend: backend)
    }

    func stopMonitoring() {
        trafficTask?.cancel(with: .goingAway, reason: nil)
        trafficTask = nil
        memoryTask?.cancel(with: .goingAway, reason: nil)
        memoryTask = nil
        connectionsTimer?.invalidate()
        connectionsTimer = nil
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        // 重新获取连接数
        await fetchConnections()
    }

    func testAllLatency() {
        // TODO
    }

    func closeAllConnections() {
        Task {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            _ = try? await apiClient.requestRaw(.closeAllConnections)
            await MainActor.run { activeConnections = 0 }
        }
    }

    // MARK: - Traffic WebSocket

    private func connectTraffic(backend: Backend) {
        let ws = backend.scheme == .https ? "wss" : "ws"
        guard let url = URL(string: "\(ws)://\(backend.host):\(backend.port)/traffic") else { return }
        var request = URLRequest(url: url)
        if let secret = backend.secret, !secret.isEmpty {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        let task = session.webSocketTask(with: request)
        trafficTask = task
        task.resume()
        receiveTraffic()
    }

    private func receiveTraffic() {
        trafficTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let up = (json["up"] as? Int64) ?? Int64(json["up"] as? Int ?? 0)
                    let down = (json["down"] as? Int64) ?? Int64(json["down"] as? Int ?? 0)
                    DispatchQueue.main.async {
                        self.uploadSpeed = up
                        self.downloadSpeed = down
                        self.appendSpeedHistory(upload: up, download: down)
                    }
                }
                self.receiveTraffic()
            case .failure:
                break
            }
        }
    }

    // MARK: - Memory WebSocket

    private func connectMemory(backend: Backend) {
        let ws = backend.scheme == .https ? "wss" : "ws"
        guard let url = URL(string: "\(ws)://\(backend.host):\(backend.port)/memory") else { return }
        var request = URLRequest(url: url)
        if let secret = backend.secret, !secret.isEmpty {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        let task = session.webSocketTask(with: request)
        memoryTask = task
        task.resume()
        receiveMemory()
    }

    private func receiveMemory() {
        memoryTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                if case .string(let text) = message,
                   let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let inuse = (json["inuse"] as? Int64) ?? Int64(json["inuse"] as? Int ?? 0)
                    DispatchQueue.main.async {
                        self.memoryUsage = inuse
                    }
                }
                self.receiveMemory()
            case .failure:
                break
            }
        }
    }

    // MARK: - Connections Polling

    private func startConnectionsPolling(backend: Backend) {
        Task { await fetchConnections() }
        connectionsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { await self?.fetchConnections() }
        }
    }

    private func fetchConnections() async {
        do {
            let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
            let data = try await apiClient.requestRaw(.getConnections)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let conns = json["connections"] as? [[String: Any]] {
                await MainActor.run {
                    activeConnections = conns.count
                    // 从顶层获取累计流量
                    if let dl = json["downloadTotal"] as? Int64 ?? (json["downloadTotal"] as? Int).map({ Int64($0) }) {
                        totalDownload = dl
                    }
                    if let ul = json["uploadTotal"] as? Int64 ?? (json["uploadTotal"] as? Int).map({ Int64($0) }) {
                        totalUpload = ul
                    }
                }
            }
        } catch {
            // 静默处理
        }
    }

    // MARK: - Speed History

    private func appendSpeedHistory(upload: Int64, download: Int64) {
        uploadHistory.append(upload)
        downloadHistory.append(download)
        if uploadHistory.count > maxHistoryCount {
            uploadHistory.removeFirst(uploadHistory.count - maxHistoryCount)
        }
        if downloadHistory.count > maxHistoryCount {
            downloadHistory.removeFirst(downloadHistory.count - maxHistoryCount)
        }
    }
}
