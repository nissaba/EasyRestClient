//
// RestEasyDefaultResponse.swift
//
// API response without data for RESTEasy framework
// Created by Pascale Beaulac
// Copyright © 2019–2025 Notio.
//

import Foundation

/// Top-level response wrapper for API requests without any data payload.
public struct RestEasyDefaultResponse: Decodable {
    public let code: Int?
    public let details: [String]?
    public let error: String?
    public let message: String?
}
