//
// RestEasyRequest.swift
//
// Request protocol for RESTEasy framework
// Created by Pascale Beaulac
// Copyright © 2019–2025 Notio.
//

import Foundation

/// Protocol defining the requirements for all RESTEasy API requests.
public protocol RestEasyRequest: Encodable {
    
    associatedtype Response: Decodable
    
    var httpMethod: HTTPMethods { get }
    var resourceName: String { get }
    var headers: [String: String]? { get }
}

// MARK: - Default implementation

public extension RestEasyRequest {
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
