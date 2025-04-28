//
// RestEasyError.swift
//
// Error types for RESTEasy framework
// Created by Pascale Beaulac
// Copyright © 2019–2025 Notio.
//

import Foundation

/// Enumeration of common RESTEasy errors.
public enum RestEasyError: Error {
    case encoding
    case decoding
    case server(message: String)
    case cannotStoreCloudId
    case badJSON
    case badResponse
    case badDataURL
    case missingCloudId
    case cannotStoreRide
    case authTokenMissing
    case sslError(message: String)
    case badStatusCode(Int)
}
