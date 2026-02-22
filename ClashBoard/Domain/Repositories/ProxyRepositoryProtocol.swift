//
//  ProxyRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

protocol ProxyRepositoryProtocol {
    func fetchProxies() async throws -> [ProxyGroup]
    func selectProxy(groupName: String, proxyName: String) async throws
    func testLatency(proxyName: String, url: String, timeout: Int) async throws -> Int
    func updateProvider(name: String) async throws
    func healthCheckProvider(name: String) async throws
    var proxyUpdates: AnyPublisher<[ProxyGroup], Never> { get }
}
