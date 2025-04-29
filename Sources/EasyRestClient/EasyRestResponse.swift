//
// EasyRestResponse.swift
//
// Generic API response for EasyREST framework
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
//
// Licensed under the MIT License.
//

import Foundation

/// Generic top-level response wrapper for API requests with a data payload.
public struct EasyRestResponse<Response: Decodable>: Decodable {
    public let code: Int?
    public let details: [String]?
    public let error: String?
    public let message: String?
    public let data: Response?
}
