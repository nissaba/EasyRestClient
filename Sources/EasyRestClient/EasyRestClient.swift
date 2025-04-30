///
/// EazyRestClient
///
/// A lightweight, protocol-oriented HTTP client for making REST API calls.
/// Supports both callback-based and async/await APIs (async/await requires iOS 15+/macOS 12+/tvOS 15+/watchOS 8+).
///
/// Usage:
/// ```swift
/// let client = EazyRestClient(baseURL: "https://api.example.com/")
/// client.authToken = "Bearer token"
///
/// // Callback version:
/// client.send(MyRequest()) { result in
///     switch result {
///     case .success(let response): print(response)
///     case .failure(let error): print(error)
///     }
/// }
///
/// // Async/Await version (iOS 15+, macOS 12+):
/// Task {
///     do {
///         let response = try await client.send(MyRequest())
///         print(response)
///     } catch {
///         print(error)
///     }
/// }
/// ```

import Foundation

/// Typealias for callback-based completion handlers.
public typealias ResultCallback<T> = @Sendable (Result<T, Error>) -> Void

/// Main HTTP client class for EazyRestClient.
/// Handles request building, header injection, and response decoding.
public class EazyRestClient {
    private let session: URLSession
    private let baseURL: URL

    /// Optional Authorization token. If set, added as `Authorization` header.
    public var authToken: String?

    /// Initializes the HTTP client with a base URL string and optional URLSession.
    /// - Parameters:
    ///   - baseURL: The root endpoint for all requests (e.g. "https://api.example.com/").
    ///   - session: URLSession instance to use; defaults to `URLSession.shared`.
    public init(baseURL: String, session: URLSession = .shared) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
    }

    // MARK: - Callback version (iOS 13+ / macOS 10.15+)

    /// Sends a `EazyRestRequest` using a callback-based API.
    /// - Parameters:
    ///   - request: An object conforming to `EazyRestRequest`.
    ///   - completion: Closure called on the main thread with a `Result` of decoded response or error.
    public func send<Request: EazyRestRequest>(
        _ request: Request,
        completion: @escaping ResultCallback<Request.Response>
    ) {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(for: request)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                return DispatchQueue.main.async {
                    completion(.failure(EazyRestError.transportError(error)))
                }
            }
            guard let http = response as? HTTPURLResponse else {
                return DispatchQueue.main.async {
                    completion(.failure(EazyRestError.badResponse))
                }
            }
            guard (200..<300).contains(http.statusCode) else {
                return DispatchQueue.main.async {
                    completion(.failure(EazyRestError.serverError(http.statusCode)))
                }
            }
            guard let data = data else {
                return DispatchQueue.main.async {
                    completion(.failure(EazyRestError.badResponse))
                }
            }
            do {
                let decoded = try JSONDecoder().decode(Request.Response.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(EazyRestError.decodingError(error)))
                }
            }
        }
        task.resume()
    }

    // MARK: - Async/Await version (iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    /// Sends a `EazyRestRequest` using Swift concurrency (`async/await`).
    /// - Parameter request: An object conforming to `EazyRestRequest`.
    /// - Returns: The decoded response of type `Request.Response`.
    /// - Throws: `EazyRestError` on failure.
    public func send<Request: EazyRestRequest>(
        _ request: Request
    ) async throws -> Request.Response {
        let urlRequest = try buildURLRequest(for: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw EazyRestError.serverError((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        return try JSONDecoder().decode(Request.Response.self, from: data)
    }

    // MARK: - Request builder

    /// Internal helper to construct a `URLRequest` from a `EazyRestRequest`.
    /// - Parameter request: The request object containing resource, query items, headers, and body data.
    /// - Returns: A configured `URLRequest`.
    /// - Throws: `EazyRestError.invalidURL` if the URL is invalid or cannot be constructed.
    private func buildURLRequest<Request: EazyRestRequest>(
        for request: Request
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(request.resourceName),
            resolvingAgainstBaseURL: true
        ) else {
            throw EazyRestError.invalidURL
        }
        if let items = request.queryItems {
            components.queryItems = items
        }
        guard let url = components.url else {
            throw EazyRestError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpShouldHandleCookies = false

        if let token = authToken {
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        }
        request.headers?.forEach { key, val in
            urlRequest.setValue(val, forHTTPHeaderField: key)
        }

        if let body = request.bodyData {
            urlRequest.httpBody = body
        } else if request.httpMethod == .post || request.httpMethod == .put {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        }

        return urlRequest
    }
}
