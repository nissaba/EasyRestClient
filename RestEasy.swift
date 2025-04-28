//
// RestEasy.swift
//
// Main REST client for RESTEasy framework
//
// Created and maintained by Pascale Beaulac
// Copyright © 2019–2025 Pascale Beaulac
//
// Licensed under the MIT License.
//

import Foundation

/// Generic, protocol-based REST API client.
public class RestEasy {
    
    private static var baseHostUrl: String?
    private let baseHostUrl: URL!
    private let session = URLSession(configuration: .default)
    private let token: String
    
    /// Initializes the RESTEasy client.
    ///
    /// - Parameters:
    ///   - token: Authorization token.
    ///   - baseUrl: Base URL string for the server.
    public init(token: String, baseUrl: String) {
        self.token = token
        self.baseHostUrl = URL(string: baseUrl)!
    }
    
    /// Sets the global environment URL for all requests.
    public class func setEnvironmentUrl(hostUrl: String) {
        RestEasy.baseHostUrl = hostUrl
    }
    
    /// Sends an API request conforming to `RestEasyRequest`.
    ///
    /// - Parameters:
    ///   - request: Type-safe request object.
    ///   - completion: Completion handler with decoded response or error.
    public func send<T: RestEasyRequest>(_ request: T, completion: @escaping ResultCallback<T.Response>) {
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
        urlRequest.addValue(self.token, forHTTPHeaderField: "Authorization")
        
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
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
                    completion(.failure(RestEasyError.badResponse))
                }
                return
            }
            
            do {
                if T.Response.self == Data.self {
                    // Special case: Raw Data download
                    DispatchQueue.main.async {
                        completion(.success(data as! T.Response))
                    }
                } else {
                    // Decode the expected Response type
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

    
    /// Builds a full URL for a given request.
    private func endpoint<T: RestEasyRequest>(for request: T) -> URL {
        guard let url = URL(string: request.resourceName, relativeTo: baseHostUrl) else {
            fatalError("Bad resourceName: \(request.resourceName)")
        }
        return url
    }
}
