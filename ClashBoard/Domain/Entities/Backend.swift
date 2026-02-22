//
//  Backend.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct Backend: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var host: String
    var port: String
    var scheme: BackendScheme
    var secret: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        label: String,
        host: String,
        port: String,
        scheme: BackendScheme = .http,
        secret: String? = nil,
        isActive: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.host = host
        self.port = port
        self.scheme = scheme
        self.secret = secret
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var baseURL: URL? {
        let urlString = "\(scheme.rawValue)://\(host):\(port)"
        return URL(string: urlString)
    }
}

enum BackendScheme: String, Codable, CaseIterable {
    case http
    case https

    var displayName: String {
        rawValue.uppercased()
    }
}

// MARK: - Mock Data

#if DEBUG
extension Backend {
    static func mock() -> Backend {
        Backend(
            label: "本地服务器",
            host: "127.0.0.1",
            port: "9090",
            scheme: .http,
            secret: "your-secret-key",
            isActive: true
        )
    }
}
#endif
