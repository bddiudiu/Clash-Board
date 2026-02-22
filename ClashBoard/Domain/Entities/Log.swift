//
//  Log.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct Log: Identifiable, Codable, Equatable {
    let id: String
    let type: LogLevel
    let payload: String
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        type: LogLevel,
        payload: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.payload = payload
        self.timestamp = timestamp
    }
}

enum LogLevel: String, Codable, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case silent = "silent"

    var displayName: String {
        switch self {
        case .debug: return "调试"
        case .info: return "信息"
        case .warning: return "警告"
        case .error: return "错误"
        case .silent: return "静默"
        }
    }

    var icon: String {
        switch self {
        case .debug: return "ant.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        case .silent: return "speaker.slash.fill"
        }
    }

    var color: String {
        switch self {
        case .debug: return "gray"
        case .info: return "blue"
        case .warning: return "yellow"
        case .error: return "red"
        case .silent: return "gray"
        }
    }
}

// MARK: - Mock Data

#if DEBUG
extension Log {
    static func mock() -> Log {
        Log(
            type: .info,
            payload: "[TCP] 192.168.1.100:54321 --> www.google.com:443 match DOMAIN-SUFFIX(google.com) using 香港 01"
        )
    }
}
#endif
