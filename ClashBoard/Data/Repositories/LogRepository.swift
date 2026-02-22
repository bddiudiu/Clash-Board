//
//  LogRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class LogRepository: LogRepositoryProtocol {

    // MARK: - Properties

    private let webSocketManager: WebSocketManagerProtocol

    private let logSubject = PassthroughSubject<Log, Never>()

    var logUpdates: AnyPublisher<Log, Never> {
        logSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(webSocketManager: WebSocketManagerProtocol) {
        self.webSocketManager = webSocketManager

        setupWebSocketListener()
    }

    // MARK: - Private Methods

    private func setupWebSocketListener() {
        webSocketManager.messagePublisher
            .sink { [weak self] message in
                if case .log(let log) = message {
                    self?.logSubject.send(log)
                }
            }
            .store(in: &cancellables)
    }
}
