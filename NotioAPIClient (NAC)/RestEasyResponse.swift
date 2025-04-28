//
// RestEasyResponse.swift
//
// Generic API response for RESTEasy framework
// Created by Pascale Beaulac
// Copyright © 2019–2025 Notio.
//

import Foundation

/// Generic top-level response wrapper for API requests with a data payload.
public struct RestEasyResponse<Response: Decodable>: Decodable {
    public let code: Int?
    public let details: [String]?
    public let error: String?
    public let message: String?
    public let data: Response?
}
