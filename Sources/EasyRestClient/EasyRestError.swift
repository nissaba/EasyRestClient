//
// EazyRestError.swift
//
// MIT License
//

import Foundation

public enum EazyRestError: Error {
    case invalidURL
    case badResponse
    case serverError(Int)
    case decodingError(Error)
    case transportError(Error)
}

extension EazyRestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .badResponse:
            return "Invalid or missing response."
        case .serverError(let code):
            return "Server returned status code \(code)."
        case .decodingError(let err):
            return "Decoding failed: \(err.localizedDescription)"
        case .transportError(let err):
            return "Network error: \(err.localizedDescription)"
        }
    }
}
