//
//  SpeedChartView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-21.
//

import SwiftUI

struct SpeedChartView: View {
    let uploadHistory: [Int64]
    let downloadHistory: [Int64]
    let maxPoints: Int

    init(uploadHistory: [Int64], downloadHistory: [Int64], maxPoints: Int = 60) {
        self.uploadHistory = uploadHistory
        self.downloadHistory = downloadHistory
        self.maxPoints = maxPoints
    }

    private var peakValue: Int64 {
        let maxUp = uploadHistory.max() ?? 0
        let maxDown = downloadHistory.max() ?? 0
        return max(max(maxUp, maxDown), 1024) // 最低 1KB 刻度
    }

    var body: some View {
        VStack(spacing: 8) {
            // 峰值标签
            HStack {
                Text(ByteFormatter.formatSpeed(peakValue))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                Spacer()
                HStack(spacing: 12) {
                    legendItem(color: .blue, label: "上传")
                    legendItem(color: .green, label: "下载")
                }
            }

            // 图表区域
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    // 网格线
                    gridLines(width: width, height: height)

                    // 下载填充区域 (绿色)
                    areaPath(data: downloadHistory, width: width, height: height)
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.green.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 上传填充区域 (蓝色)
                    areaPath(data: uploadHistory, width: width, height: height)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 下载线条
                    linePath(data: downloadHistory, width: width, height: height)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

                    // 上传线条
                    linePath(data: uploadHistory, width: width, height: height)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: 120)

            // 底部零线标签
            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("最近 \(maxPoints) 秒")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Chart Paths

    private func linePath(data: [Int64], width: CGFloat, height: CGFloat) -> Path {
        guard data.count >= 2 else {
            return Path()
        }

        let peak = Double(peakValue)
        let count = maxPoints
        let stepX = width / CGFloat(max(count - 1, 1))

        // 数据从右向左显示（最新在右边）
        let startIndex = max(0, count - data.count)

        return Path { path in
            for (i, value) in data.enumerated() {
                let x = CGFloat(startIndex + i) * stepX
                let y = height - (CGFloat(Double(value) / peak) * height)
                let clampedY = min(max(y, 0), height)

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: clampedY))
                } else {
                    path.addLine(to: CGPoint(x: x, y: clampedY))
                }
            }
        }
    }

    private func areaPath(data: [Int64], width: CGFloat, height: CGFloat) -> Path {
        guard data.count >= 2 else {
            return Path()
        }

        let peak = Double(peakValue)
        let count = maxPoints
        let stepX = width / CGFloat(max(count - 1, 1))
        let startIndex = max(0, count - data.count)

        return Path { path in
            let firstX = CGFloat(startIndex) * stepX
            let firstY = height - (CGFloat(Double(data[0]) / peak) * height)
            path.move(to: CGPoint(x: firstX, y: min(max(firstY, 0), height)))

            for (i, value) in data.enumerated() {
                let x = CGFloat(startIndex + i) * stepX
                let y = height - (CGFloat(Double(value) / peak) * height)
                path.addLine(to: CGPoint(x: x, y: min(max(y, 0), height)))
            }

            // 封闭底部
            let lastX = CGFloat(startIndex + data.count - 1) * stepX
            path.addLine(to: CGPoint(x: lastX, y: height))
            path.addLine(to: CGPoint(x: firstX, y: height))
            path.closeSubpath()
        }
    }

    // MARK: - Grid

    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            let rows = 3
            for i in 1..<rows {
                let y = height * CGFloat(i) / CGFloat(rows)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color(.separator).opacity(0.3), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
    }

    // MARK: - Legend

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    SpeedChartView(
        uploadHistory: (0..<30).map { _ in Int64.random(in: 0...1_000_000) },
        downloadHistory: (0..<30).map { _ in Int64.random(in: 0...5_000_000) }
    )
    .padding()
}
#endif
