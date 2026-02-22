//
//  WebSocketManager.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

enum WebSocketMessage {
    case traffic(TrafficSnapshot)
    case memory(MemoryUsage)
    case log(Log)
    case connections([Connection])
    case error(Error)
}

protocol WebSocketManagerProtocol: AnyObject {
    func connect(to backend: Backend, endpoint: APIEndpoint)
    func disconnect(endpoint: APIEndpoint)
    func disconnectAll()
    var messagePublisher: AnyPublisher<WebSocketMessage, Never> { get }
}

final class WebSocketManager: WebSocketManagerProtocol {

    // MARK: - Properties

    private var tasks: [String: URLSessionWebSocketTask] = [:]
    private let session: URLSession
    private let messageSubject = PassthroughSubject<WebSocketMessage, Never>()
    private var retryTimers: [String: Timer] = [:]
    private var retryAttempts: [String: Int] = [:]
    private var heartbeatTimers: [String: Timer] = [:]
    private let maxRetryDelay: TimeInterval = 30
    private let heartbeatInterval: TimeInterval = 30
    private let maxRetryAttempts = 10

    var messagePublisher: AnyPublisher<WebSocketMessage, Never> {
        messageSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session
    }

    deinit {
        disconnectAll()
    }

    // MARK: - Public Methods

    func connect(to backend: Backend, endpoint: APIEndpoint) {
        let key = endpoint.path
        disconnect(endpoint: endpoint)

        guard let url = buildWebSocketURL(backend: backend, endpoint: endpoint) else {
            messageSubject.send(.error(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        if let secret = backend.secret, !secret.isEmpty {
            request.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
        }

        let task = session.webSocketTask(with: request)
        tasks[key] = task
        task.resume()

        // 重置重试计数
        retryAttempts[key] = 0

        // 开始接收消息
        receiveMessage(for: key, endpoint: endpoint, backend: backend)

        // 启动心跳检测
        startHeartbeat(for: key)
    }

    func disconnect(endpoint: APIEndpoint) {
        let key = endpoint.path
        tasks[key]?.cancel(with: .goingAway, reason: nil)
        tasks.removeValue(forKey: key)
        retryTimers[key]?.invalidate()
        retryTimers.removeValue(forKey: key)
        retryAttempts.removeValue(forKey: key)
        heartbeatTimers[key]?.invalidate()
        heartbeatTimers.removeValue(forKey: key)
    }

    func disconnectAll() {
        tasks.values.forEach { $0.cancel(with: .goingAway, reason: nil) }
        tasks.removeAll()
        retryTimers.values.forEach { $0.invalidate() }
        retryTimers.removeAll()
        retryAttempts.removeAll()
        heartbeatTimers.values.forEach { $0.invalidate() }
        heartbeatTimers.removeAll()
    }

    // MARK: - Private Methods

    private func buildWebSocketURL(backend: Backend, endpoint: APIEndpoint) -> URL? {
        let wsProtocol = backend.scheme == .https ? "wss" : "ws"
        var components = URLComponents()
        components.scheme = wsProtocol
        components.host = backend.host
        components.port = Int(backend.port)
        components.path = endpoint.path

        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems
        }

        return components.url
    }

    private func receiveMessage(for key: String, endpoint: APIEndpoint, backend: Backend) {
        guard let task = tasks[key] else { return }

        task.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                self.handleMessage(message, for: endpoint)
                self.receiveMessage(for: key, endpoint: endpoint, backend: backend)

            case .failure(let error):
                self.messageSubject.send(.error(error))
                self.scheduleReconnect(key: key, endpoint: endpoint, backend: backend)
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message, for endpoint: APIEndpoint) {
        switch message {
        case .string(let text):
            parseMessage(text, for: endpoint)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                parseMessage(text, for: endpoint)
            }
        @unknown default:
            break
        }
    }

    private func parseMessage(_ text: String, for endpoint: APIEndpoint) {
        guard let data = text.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        switch endpoint {
        case .getTraffic:
            if let traffic = try? decoder.decode(TrafficSnapshot.self, from: data) {
                messageSubject.send(.traffic(traffic))
            }
        case .getMemory:
            if let memory = try? decoder.decode(MemoryUsage.self, from: data) {
                messageSubject.send(.memory(memory))
            }
        case .getLogs:
            if let log = try? decoder.decode(Log.self, from: data) {
                messageSubject.send(.log(log))
            }
        default:
            break
        }
    }

    private func scheduleReconnect(key: String, endpoint: APIEndpoint, backend: Backend) {
        // 获取当前重试次数
        let attempts = retryAttempts[key] ?? 0

        // 检查是否超过最大重试次数
        guard attempts < maxRetryAttempts else {
            messageSubject.send(.error(NetworkError.webSocketError("Max retry attempts reached")))
            return
        }

        // 计算指数退避延迟：2^attempts 秒，最大 30 秒
        let delay = min(pow(2.0, Double(attempts)), maxRetryDelay)

        // 增加重试计数
        retryAttempts[key] = attempts + 1

        // 取消之前的重试定时器
        retryTimers[key]?.invalidate()

        // 创建新的重试定时器
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.connect(to: backend, endpoint: endpoint)
        }

        retryTimers[key] = timer
    }

    private func startHeartbeat(for key: String) {
        // 取消之前的心跳定时器
        heartbeatTimers[key]?.invalidate()

        // 创建心跳定时器
        let timer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            guard let self = self, let task = self.tasks[key] else { return }

            // 发送 ping 消息
            task.sendPing { error in
                if let error = error {
                    print("WebSocket ping failed: \(error.localizedDescription)")
                }
            }
        }

        heartbeatTimers[key] = timer
    }
}
