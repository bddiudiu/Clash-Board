//
//  Traffic.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct Traffic: Codable, Equatable {
    let upload: Int64
    let download: Int64
    let timestamp: Date

    init(
        upload: Int64,
        download: Int64,
        timestamp: Date = Date()
    ) {
        self.upload = upload
        self.download = download
        self.timestamp = timestamp
    }

    var total: Int64 {
        upload + download
    }
}

struct TrafficSnapshot: Identifiable, Codable, Equatable {
    let id: String
    let uploadSpeed: Int64
    let downloadSpeed: Int64
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case up, down
    }

    init(
        id: String = UUID().uuidString,
        uploadSpeed: Int64,
        downloadSpeed: Int64,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.uploadSpeed = uploadSpeed
        self.downloadSpeed = downloadSpeed
        self.timestamp = timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.uploadSpeed = try container.decode(Int64.self, forKey: .up)
        self.downloadSpeed = try container.decode(Int64.self, forKey: .down)
        self.timestamp = Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uploadSpeed, forKey: .up)
        try container.encode(downloadSpeed, forKey: .down)
    }

    var totalSpeed: Int64 {
        uploadSpeed + downloadSpeed
    }
}

struct MemoryUsage: Codable, Equatable {
    let inuse: Int64

    init(inuse: Int64) {
        self.inuse = inuse
    }
}

// MARK: - Mock Data

#if DEBUG
extension Traffic {
    static func mock() -> Traffic {
        Traffic(
            upload: 1024 * 1024 * 100,
            download: 1024 * 1024 * 500
        )
    }
}

extension TrafficSnapshot {
    static func mock() -> TrafficSnapshot {
        TrafficSnapshot(
            uploadSpeed: 1024 * 100,
            downloadSpeed: 1024 * 500
        )
    }
}

extension MemoryUsage {
    static func mock() -> MemoryUsage {
        MemoryUsage(
            inuse: 1024 * 1024 * 50
        )
    }
}
#endif
