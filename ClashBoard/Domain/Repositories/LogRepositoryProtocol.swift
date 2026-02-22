//
//  LogRepositoryProtocol.swift
//  ClashBoard
//
//  Created by Merlin Clash Team on 2026-02-20.
//

import Foundation
import Combine

protocol LogRepositoryProtocol {
    var logUpdates: AnyPublisher<Log, Never> { get }
}
