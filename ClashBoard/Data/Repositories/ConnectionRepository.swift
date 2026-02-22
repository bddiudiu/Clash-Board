//
//  ConnectionRepository.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

final class ConnectionRepository: ConnectionRepositoryProtocol {

    // MARK: - Properties

    private let remoteDataSource: ConnectionRemoteDataSource
    private let webSocketManager: WebSocketManagerProtocol

    private let connectionSubject = CurrentValueSubject<[Connection], Never>([])
    private var cancellables = Set<AnyCancellable>()

    var connectionUpdates: AnyPublisher<[Connection], Never> {
        connectionSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        remoteDataSource: ConnectionRemoteDataSource,
        webSocketManager: WebSocketManagerProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.webSocketManager = webSocketManager

        setupWebSocketListener()
    }

    // MARK: - Public Methods

    func fetchConnections() async throws -> [Connection] {
        let response = try await remoteDataSource.fetchConnections()
        connectionSubject.send(response.connections)
        return response.connections
    }

    func closeConnection(id: String) async throws {
        try await remoteDataSource.closeConnection(id: id)

        // 更新本地状态
        var currentConnections = connectionSubject.value
        currentConnections.removeAll { $0.id == id }
        connectionSubject.send(currentConnections)
    }

    func closeAllConnections() async throws {
        try await remoteDataSource.closeAllConnections()
        connectionSubject.send([])
    }

    // MARK: - Private Methods

    private func setupWebSocketListener() {
        webSocketManager.messagePublisher
            .sink { [weak self] message in
                if case .connections(let connections) = message {
                    self?.connectionSubject.send(connections)
                }
            }
            .store(in: &cancellables)
    }
}
