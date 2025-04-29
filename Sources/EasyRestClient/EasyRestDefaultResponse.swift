//
// EasyRestDefaultResponse.swift
//
// API response without data for RESTEasy framework
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
//
// Licensed under the MIT License.
//

import Foundation

/// Top-level response wrapper for API requests without any data payload.
public struct EasyRestDefaultResponse: Decodable {
    public let code: Int?
    public let details: [String]?
    public let error: String?
    public let message: String?
}
