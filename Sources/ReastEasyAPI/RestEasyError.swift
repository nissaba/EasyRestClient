//
//  RestEasyError.swift
//  PatsRestService
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
//
// Licensed under the MIT License.
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
