//
//  MockURLProtocol.swift
//  EazyRestClient
//
//  Created by Pascale on 2025-04-29.
//


//
//  EazyRestClientTests.swift
//  EazyRestClientTests
//
//  Created by Pascale on 2025-04-29.
//

import XCTest
@testable import EazyRestClient

/// URLProtocol stub to intercept network calls and return custom responses.
class MockURLProtocol: URLProtocol {
    /// Handler to be set in tests to return data, response or throw error.
    static var requestHandler: ((URLRequest) throws -> (Data, HTTPURLResponse))?

    override class func canInit(with request: URLRequest) -> Bool {
        // Intercept all requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler not set.")
        }

        do {
            let (data, response) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Required override. No cleanup needed.
    }
}



final class EazyRestClientTests: XCTestCase {
    var client: EazyRestClient!

    override func setUp() {
        super.setUp()
        // Configure URLSession to use MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        client = EazyRestClient(baseURL: "https://example.com", session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        client = nil
        super.tearDown()
    }
     
    struct TestResponse: Codable {
        let value: String
    }

    struct DummyRequest: EazyRestRequest {
        typealias Response = TestResponse
        var httpMethod: HTTPMethods { .get }
        var resourceName: String { "path" }
        // `queryItems` and `bodyData` use the protocol’s default implementations
    }
    
    func testSuccessCallback() {
        // Prepare mock to return valid JSON and HTTP 200
        let expected = TestResponse(value: "hello")
        let jsonData = try! JSONEncoder().encode(expected)
        let url = URL(string: "https://example.com/path")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url, url)
            return (jsonData, response)
        }

        let exp = expectation(description: "Callback completes")
        client.send(DummyRequest()) { result in
            switch result {
            case .success(let resp):
                XCTAssertEqual(resp.value, "hello")
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testServerErrorCallback() {
        let url = URL(string: "https://example.com/path")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { request in
            return (Data(), response)
        }

        let exp = expectation(description: "Server error callback")
        client.send(DummyRequest()) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to server error")
            case .failure(let error):
                if case EazyRestError.serverError(let code) = error {
                    XCTAssertEqual(code, 500)
                } else {
                    XCTFail("Expected EazyRestError.serverError, got \(error)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testDecodingErrorCallback() {
        let badJSON = "{ \"wrong\": 1 }".data(using: .utf8)!
        let url = URL(string: "https://example.com/path")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { request in
            return (badJSON, response)
        }

        let exp = expectation(description: "Decoding error callback")
        client.send(DummyRequest()) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to decoding error")
            case .failure(let error):
                if case EazyRestError.decodingError = error {
                    // success
                } else {
                    XCTFail("Expected EazyRestError.decodingError, got \(error)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testTransportErrorCallback() {
        let expectedError = URLError(.notConnectedToInternet)
        MockURLProtocol.requestHandler = { request in
            throw expectedError
        }

        let exp = expectation(description: "Transport error callback")
        client.send(DummyRequest()) { result in
            switch result {
            case .success:
                XCTFail("Expected transport error failure")
            case .failure(let error):
                if case EazyRestError.transportError(let underlying) = error {
                    XCTAssertEqual((underlying as? URLError)?.code, .notConnectedToInternet)
                } else {
                    XCTFail("Expected EazyRestError.transportError, got \(error)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // Async tests for async/await version
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testSuccessAsync() async throws {
        let expected = TestResponse(value: "async")
        let data = try JSONEncoder().encode(expected)
        let url = URL(string: "https://example.com/path")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { _ in (data, response) }

        let resp = try await client.send(DummyRequest())
        XCTAssertEqual(resp.value, "async")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testServerErrorAsync() async {
        let url = URL(string: "https://example.com/path")!
        let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        MockURLProtocol.requestHandler = { _ in (Data(), response) }

        do {
            _ = try await client.send(DummyRequest())
            XCTFail("Expected server error")
        } catch EazyRestError.serverError(let code) {
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Expected EazyRestError.serverError, got \(error)")
        }
    }
}
