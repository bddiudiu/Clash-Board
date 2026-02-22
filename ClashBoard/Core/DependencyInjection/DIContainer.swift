//
//  DIContainer.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()

    private var services: [String: Any] = [:]

    private init() {}

    // MARK: - Registration

    func register() {
        registerNetworkServices()
        registerStorageServices()
        registerRepositories()
        registerUseCases()
    }

    private func registerNetworkServices() {
        // API Client
        let apiClient = ClashAPIClient()
        register(apiClient, for: APIClientProtocol.self)

        // WebSocket Manager
        let webSocketManager = WebSocketManager()
        register(webSocketManager, for: WebSocketManagerProtocol.self)
    }

    private func registerStorageServices() {
        // Keychain Storage
        let keychainStorage = KeychainStorage()
        register(keychainStorage, for: KeychainStorageProtocol.self)

        // UserDefaults Storage
        let userDefaultsStorage = UserDefaultsStorage()
        register(userDefaultsStorage, for: UserDefaultsStorageProtocol.self)
    }

    private func registerRepositories() {
        // Data Sources
        let backendLocalDataSource = BackendLocalDataSource(
            storage: resolve(UserDefaultsStorageProtocol.self)
        )
        register(backendLocalDataSource, for: BackendLocalDataSource.self)

        let proxyRemoteDataSource = ProxyRemoteDataSource(
            apiClient: resolve(APIClientProtocol.self)
        )
        register(proxyRemoteDataSource, for: ProxyRemoteDataSource.self)

        let connectionRemoteDataSource = ConnectionRemoteDataSource(
            apiClient: resolve(APIClientProtocol.self)
        )
        register(connectionRemoteDataSource, for: ConnectionRemoteDataSource.self)

        let ruleRemoteDataSource = RuleRemoteDataSource(
            apiClient: resolve(APIClientProtocol.self)
        )
        register(ruleRemoteDataSource, for: RuleRemoteDataSource.self)

        let configRemoteDataSource = ConfigRemoteDataSource(
            apiClient: resolve(APIClientProtocol.self)
        )
        register(configRemoteDataSource, for: ConfigRemoteDataSource.self)

        // Backend Repository
        let backendRepository = BackendRepository(
            localStorage: resolve(BackendLocalDataSource.self),
            keychainStorage: resolve(KeychainStorageProtocol.self),
            apiClient: resolve(APIClientProtocol.self)
        )
        register(backendRepository, for: BackendRepositoryProtocol.self)

        // Proxy Repository
        let proxyRepository = ProxyRepository(
            remoteDataSource: resolve(ProxyRemoteDataSource.self),
            webSocketManager: resolve(WebSocketManagerProtocol.self)
        )
        register(proxyRepository, for: ProxyRepositoryProtocol.self)

        // Connection Repository
        let connectionRepository = ConnectionRepository(
            remoteDataSource: resolve(ConnectionRemoteDataSource.self),
            webSocketManager: resolve(WebSocketManagerProtocol.self)
        )
        register(connectionRepository, for: ConnectionRepositoryProtocol.self)

        // Rule Repository
        let ruleRepository = RuleRepository(
            remoteDataSource: resolve(RuleRemoteDataSource.self)
        )
        register(ruleRepository, for: RuleRepositoryProtocol.self)

        // Log Repository
        let logRepository = LogRepository(
            webSocketManager: resolve(WebSocketManagerProtocol.self)
        )
        register(logRepository, for: LogRepositoryProtocol.self)

        // Config Repository
        let configRepository = ConfigRepository(
            remoteDataSource: resolve(ConfigRemoteDataSource.self)
        )
        register(configRepository, for: ConfigRepositoryProtocol.self)
    }

    private func registerUseCases() {
        // Backend Use Cases
        register(
            AddBackendUseCase(repository: resolve(BackendRepositoryProtocol.self)),
            for: AddBackendUseCase.self
        )
        register(
            DeleteBackendUseCase(repository: resolve(BackendRepositoryProtocol.self)),
            for: DeleteBackendUseCase.self
        )
        register(
            SwitchBackendUseCase(repository: resolve(BackendRepositoryProtocol.self)),
            for: SwitchBackendUseCase.self
        )
        register(
            TestBackendUseCase(repository: resolve(BackendRepositoryProtocol.self)),
            for: TestBackendUseCase.self
        )

        // Proxy Use Cases
        register(
            FetchProxiesUseCase(repository: resolve(ProxyRepositoryProtocol.self)),
            for: FetchProxiesUseCase.self
        )
        register(
            SelectProxyUseCase(repository: resolve(ProxyRepositoryProtocol.self)),
            for: SelectProxyUseCase.self
        )
        register(
            TestProxyLatencyUseCase(repository: resolve(ProxyRepositoryProtocol.self)),
            for: TestProxyLatencyUseCase.self
        )
        register(
            UpdateProxyProviderUseCase(repository: resolve(ProxyRepositoryProtocol.self)),
            for: UpdateProxyProviderUseCase.self
        )

        // Connection Use Cases
        register(
            FetchConnectionsUseCase(repository: resolve(ConnectionRepositoryProtocol.self)),
            for: FetchConnectionsUseCase.self
        )
        register(
            CloseConnectionUseCase(repository: resolve(ConnectionRepositoryProtocol.self)),
            for: CloseConnectionUseCase.self
        )
        register(
            CloseAllConnectionsUseCase(repository: resolve(ConnectionRepositoryProtocol.self)),
            for: CloseAllConnectionsUseCase.self
        )

        // Rule Use Cases
        register(
            FetchRulesUseCase(repository: resolve(RuleRepositoryProtocol.self)),
            for: FetchRulesUseCase.self
        )
        register(
            ToggleRuleUseCase(repository: resolve(RuleRepositoryProtocol.self)),
            for: ToggleRuleUseCase.self
        )
    }

    // MARK: - Resolution

    func register<T>(_ service: T, for type: T.Type) {
        let key = String(describing: type)
        services[key] = service
    }

    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("Service \(key) not registered")
        }
        return service
    }
}
