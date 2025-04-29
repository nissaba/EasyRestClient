//
// EasyRestClient.swift
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
// Licensed under the MIT License.
//

import Foundation

/// Typealias for completion callbacks returning a Result.
/// Safe for concurrency use (`@Sendable`).
public typealias ResultCallback<T> = @Sendable (Result<T, Error>) -> Void


/// Generic, protocol-based REST API client.
public class EasyRestClient {
    
    private let baseHostUrl: URL!
    private let session = URLSession(configuration: .default)
    
    /// Optional Authorization token
    public var authToken: String?

    /// Initializes the RESTEasy client.
    /// - Parameter baseUrl: Base URL string for the server.
    public init(baseUrl: String) {
        self.baseHostUrl = URL(string: baseUrl)!
    }

    
    /// Sends an API request conforming to `RestEasyRequest`.
    ///
    /// - Parameters:
    ///   - request: Type-safe request object.
    ///   - completion: Completion handler with decoded response or error.
    public func send<T: EasyResRequest>(
        _ request: T,
        completion: @escaping ResultCallback<T.Response>
    ) {
        var endpoint = URL(string: request.resourceName, relativeTo: baseHostUrl)!

        // If query items exist, append them
        if let queryItems = request.queryItems {
            var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)!
            components.queryItems = queryItems
            endpoint = components.url!
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpShouldHandleCookies = false

        // Inject Authorization header if token is available
        if let token = authToken {
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        }

        // Inject request-specific headers
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Inject body data if available
        if let bodyData = request.bodyData {
            urlRequest.httpBody = bodyData
        } else if request.httpMethod == .post || request.httpMethod == .put {
            urlRequest.httpBody = try? JSONEncoder().encode(request)
        }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(EasyRestError.badResponse))
                }
                return
            }

            do {
                if T.Response.self == Data.self {
                    // Special case for raw Data downloads
                    DispatchQueue.main.async {
                        completion(.success(data as! T.Response))
                    }
                } else {
                    let decoded = try T.Response.decode(from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
}
