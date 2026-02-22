//
//  LogViewModel.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class LogViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var logs: [Log] = []
    @Published var isPaused = false
    @Published var selectedLevels: Set<LogLevel> = [.info, .warning, .error]

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let webSocketManager: WebSocketManagerProtocol
    private let maxLogCount = 1000

    // MARK: - Initialization

    init(webSocketManager: WebSocketManagerProtocol? = nil) {
        self.webSocketManager = webSocketManager ?? DIContainer.shared.resolve(WebSocketManagerProtocol.self)
    }

    // MARK: - Public Methods

    func startMonitoring() {
        webSocketManager.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self, !self.isPaused else { return }
                if case .log(let log) = message {
                    self.appendLog(log)
                }
            }
            .store(in: &cancellables)
    }

    func stopMonitoring() {
        cancellables.removeAll()
    }

    func clearLogs() {
        logs.removeAll()
    }

    func toggleLevel(_ level: LogLevel) {
        if selectedLevels.contains(level) {
            selectedLevels.remove(level)
        } else {
            selectedLevels.insert(level)
        }
    }

    // MARK: - Private Methods

    private func appendLog(_ log: Log) {
        logs.append(log)
        if logs.count > maxLogCount {
            logs.removeFirst(logs.count - maxLogCount)
        }
    }
}
