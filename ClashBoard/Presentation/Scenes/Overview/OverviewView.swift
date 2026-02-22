//
//  OverviewView.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import SwiftUI

struct OverviewView: View {
    @StateObject private var viewModel = OverviewViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 速度卡片
                speedCard

                // 流量统计
                trafficCard

                // 连接数和内存
                HStack(spacing: 12) {
                    connectionCard
                    memoryCard
                }

                // 快速操作
                quickActionsCard
            }
            .padding()
        }
        .navigationTitle("概览")
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    // MARK: - Speed Card

    private var speedCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("实时速度")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("上传")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(ByteFormatter.formatSpeed(viewModel.uploadSpeed))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("下载")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(ByteFormatter.formatSpeed(viewModel.downloadSpeed))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }

                Spacer()
            }

            SpeedChartView(
                uploadHistory: viewModel.uploadHistory,
                downloadHistory: viewModel.downloadHistory
            )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Traffic Card

    private var trafficCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("流量统计")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("上传")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ByteFormatter.format(viewModel.totalUpload))
                        .font(.body)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("下载")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ByteFormatter.format(viewModel.totalDownload))
                        .font(.body)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Connection Card

    private var connectionCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "link")
                .font(.title2)
                .foregroundColor(.blue)

            Text("\(viewModel.activeConnections)")
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()

            Text("活跃连接")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Memory Card

    private var memoryCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "memorychip")
                .font(.title2)
                .foregroundColor(.orange)

            Text(ByteFormatter.format(viewModel.memoryUsage))
                .font(.title3)
                .fontWeight(.bold)
                .monospacedDigit()

            Text("内存使用")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Quick Actions Card

    private var quickActionsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("快速操作")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 12) {
                actionButton(
                    title: "延迟测速",
                    icon: "speedometer",
                    color: .blue
                ) {
                    viewModel.testAllLatency()
                }

                actionButton(
                    title: "关闭连接",
                    icon: "xmark.circle",
                    color: .red
                ) {
                    viewModel.closeAllConnections()
                }

                actionButton(
                    title: "刷新配置",
                    icon: "arrow.clockwise",
                    color: .green
                ) {
                    Task { await viewModel.refresh() }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Action Button

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        OverviewView()
    }
}
#endif
