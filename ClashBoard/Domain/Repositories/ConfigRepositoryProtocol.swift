//
//  ConfigRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

protocol ConfigRepositoryProtocol {
    func fetchConfig() async throws -> ClashConfig
    func updateConfig(_ config: [String: Any]) async throws
    func reloadConfig(path: String, payload: String) async throws
}
