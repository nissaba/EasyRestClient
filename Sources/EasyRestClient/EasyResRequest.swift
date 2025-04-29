//
// EasyResRequest.swift
//
// Request protocol for EasyREST framework
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
//
// Licensed under the MIT License.
//

import Foundation

public protocol EasyResRequest: Encodable {
    associatedtype Response: Decodable
    
    /// HTTP method (GET, POST, PUT, DELETE, etc.)
    var httpMethod: HTTPMethods { get }
    
    /// Resource path relative to base URL.
    var resourceName: String { get }
    
    /// Headers (default: JSON unless overridden).
    var headers: [String: String]? { get }
    
    /// Optional Query Items (for GET requests typically).
    var queryItems: [URLQueryItem]? { get }
    
    /// Body Data (optional, overrides Encodable body if provided).
    var bodyData: Data? { get }
}
