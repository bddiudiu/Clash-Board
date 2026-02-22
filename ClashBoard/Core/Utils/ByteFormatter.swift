//
//  ByteFormatter.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

enum ByteFormatter {

    // MARK: - Format Bytes

    static func format(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0

        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(Int(value)) \(units[unitIndex])"
        } else {
            return String(format: "%.1f \(units[unitIndex])", value)
        }
    }

    // MARK: - Format Speed

    static func formatSpeed(_ bytesPerSecond: Int64) -> String {
        let formatted = format(bytesPerSecond)
        return "\(formatted)/s"
    }

    // MARK: - Short Format

    static func shortFormat(_ bytes: Int64) -> (value: String, unit: String) {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0

        while value >= 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }

        if unitIndex == 0 {
            return ("\(Int(value))", units[unitIndex])
        } else {
            return (String(format: "%.1f", value), units[unitIndex])
        }
    }
}

// MARK: - Latency Formatter

enum LatencyFormatter {

    static func format(_ latency: Int?) -> String {
        guard let latency = latency else {
            return "超时"
        }

        if latency <= 0 {
            return "超时"
        }

        return "\(latency) ms"
    }
}

// MARK: - Duration Formatter

enum DurationFormatter {

    static func format(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}
