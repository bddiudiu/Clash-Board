//
//  ConnectionRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

protocol ConnectionRepositoryProtocol {
    func fetchConnections() async throws -> [Connection]
    func closeConnection(id: String) async throws
    func closeAllConnections() async throws
    var connectionUpdates: AnyPublisher<[Connection], Never> { get }
}
