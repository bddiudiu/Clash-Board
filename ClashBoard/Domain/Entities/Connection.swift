//
//  Connection.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

struct Connection: Identifiable, Codable, Equatable {
    let id: String
    let metadata: ConnectionMetadata
    let upload: Int64
    let download: Int64
    var uploadSpeed: Int64
    var downloadSpeed: Int64
    let chains: [String]
    let rule: String
    let rulePayload: String
    let start: Date

    enum CodingKeys: String, CodingKey {
        case id, metadata, upload, download, chains, rule, rulePayload, start
    }

    init(
        id: String,
        metadata: ConnectionMetadata,
        upload: Int64 = 0,
        download: Int64 = 0,
        uploadSpeed: Int64 = 0,
        downloadSpeed: Int64 = 0,
        chains: [String] = [],
        rule: String = "",
        rulePayload: String = "",
        start: Date = Date()
    ) {
        self.id = id
        self.metadata = metadata
        self.upload = upload
        self.download = download
        self.uploadSpeed = uploadSpeed
        self.downloadSpeed = downloadSpeed
        self.chains = chains
        self.rule = rule
        self.rulePayload = rulePayload
        self.start = start
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        metadata = try container.decode(ConnectionMetadata.self, forKey: .metadata)
        upload = try container.decode(Int64.self, forKey: .upload)
        download = try container.decode(Int64.self, forKey: .download)
        uploadSpeed = 0
        downloadSpeed = 0
        chains = try container.decodeIfPresent([String].self, forKey: .chains) ?? []
        rule = try container.decodeIfPresent(String.self, forKey: .rule) ?? ""
        rulePayload = try container.decodeIfPresent(String.self, forKey: .rulePayload) ?? ""
        let startStr = try container.decodeIfPresent(String.self, forKey: .start) ?? ""
        start = ISO8601DateFormatter().date(from: startStr) ?? Date()
    }

    var totalTraffic: Int64 {
        upload + download
    }

    var duration: TimeInterval {
        Date().timeIntervalSince(start)
    }
}

struct ConnectionMetadata: Codable, Equatable {
    let network: String
    let type: String
    let sourceIP: String
    let destinationIP: String
    let sourcePort: String
    let destinationPort: String
    let host: String
    let dnsMode: String
    let processPath: String

    init(
        network: String = "",
        type: String = "",
        sourceIP: String = "",
        destinationIP: String = "",
        sourcePort: String = "",
        destinationPort: String = "",
        host: String = "",
        dnsMode: String = "",
        processPath: String = ""
    ) {
        self.network = network
        self.type = type
        self.sourceIP = sourceIP
        self.destinationIP = destinationIP
        self.sourcePort = sourcePort
        self.destinationPort = destinationPort
        self.host = host
        self.dnsMode = dnsMode
        self.processPath = processPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        network = try container.decodeIfPresent(String.self, forKey: .network) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        sourceIP = try container.decodeIfPresent(String.self, forKey: .sourceIP) ?? ""
        destinationIP = try container.decodeIfPresent(String.self, forKey: .destinationIP) ?? ""
        sourcePort = try container.decodeIfPresent(String.self, forKey: .sourcePort) ?? ""
        destinationPort = try container.decodeIfPresent(String.self, forKey: .destinationPort) ?? ""
        host = try container.decodeIfPresent(String.self, forKey: .host) ?? ""
        dnsMode = try container.decodeIfPresent(String.self, forKey: .dnsMode) ?? ""
        processPath = try container.decodeIfPresent(String.self, forKey: .processPath) ?? ""
    }

    var displayHost: String {
        host.isEmpty ? destinationIP : host
    }

    var displaySource: String {
        "\(sourceIP):\(sourcePort)"
    }

    var displayDestination: String {
        "\(destinationIP):\(destinationPort)"
    }
}

// MARK: - Mock Data

#if DEBUG
extension Connection {
    static func mock() -> Connection {
        Connection(
            id: UUID().uuidString,
            metadata: ConnectionMetadata(
                network: "tcp",
                type: "HTTP",
                sourceIP: "192.168.1.100",
                destinationIP: "142.250.185.46",
                sourcePort: "54321",
                destinationPort: "443",
                host: "www.google.com",
                dnsMode: "normal",
                processPath: "/Applications/Safari.app"
            ),
            upload: 1024 * 100,
            download: 1024 * 500,
            uploadSpeed: 1024 * 10,
            downloadSpeed: 1024 * 50,
            chains: ["🚀 节点选择", "香港 01"],
            rule: "DOMAIN-SUFFIX",
            rulePayload: "google.com"
        )
    }
}
#endif
