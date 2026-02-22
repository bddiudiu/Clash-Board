//
//  UserDefaultsStorage.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

protocol UserDefaultsStorageProtocol {
    func save<T: Codable>(_ value: T, for key: String)
    func load<T: Codable>(_ type: T.Type, for key: String) -> T?
    func remove(for key: String)
    func publisher<T: Codable>(for key: String, type: T.Type) -> AnyPublisher<T?, Never>
}

final class UserDefaultsStorage: UserDefaultsStorageProtocol {

    // MARK: - Properties

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Public Methods

    func save<T: Codable>(_ value: T, for key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func load<T: Codable>(_ type: T.Type, for key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    func remove(for key: String) {
        defaults.removeObject(forKey: key)
    }

    func publisher<T: Codable>(for key: String, type: T.Type) -> AnyPublisher<T?, Never> {
        defaults.publisher(for: key)
            .map { [weak self] _ in
                self?.load(type, for: key)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - UserDefaults Publisher

extension UserDefaults {
    func publisher(for key: String) -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification, object: self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// MARK: - Storage Keys

enum StorageKey {
    static let backends = "backends"
    static let activeBackendId = "activeBackendId"
    static let theme = "theme"
    static let language = "language"
    static let proxyDisplayMode = "proxyDisplayMode"
    static let connectionSortOrder = "connectionSortOrder"
    static let logLevel = "logLevel"
    static let logRetainCount = "logRetainCount"
    static let overviewCards = "overviewCards"
}
