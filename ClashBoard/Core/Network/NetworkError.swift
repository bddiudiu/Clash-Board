//
//  NetworkError.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

enum NetworkError: LocalizedError {
    case notConfigured
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case requestFailed(Error)
    case decodingFailed(Error)
    case webSocketError(String)
    case timeout
    case noConnection

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API 客户端未配置"
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "认证失败，请检查密钥"
        case .notFound:
            return "请求的资源不存在"
        case .serverError(let code):
            return "服务器错误 (\(code))"
        case .unexpectedStatusCode(let code):
            return "未知错误 (\(code))"
        case .requestFailed(let error):
            return "请求失败：\(error.localizedDescription)"
        case .decodingFailed(let error):
            return "数据解析失败：\(error.localizedDescription)"
        case .webSocketError(let message):
            return "WebSocket 错误：\(message)"
        case .timeout:
            return "请求超时"
        case .noConnection:
            return "无网络连接"
        }
    }
}
