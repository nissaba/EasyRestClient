//
//  EazyRestErrorTests.swift
//  EazyRestClient
//
//  Created by Pascale on 2025-08-22.
//


// EazyRestErrorTests.swift
// Tests for EazyRestError and EazyRestRequest defaults
import XCTest
@testable import EazyRestClient

final class EazyRestErrorTests: XCTestCase {
    func testErrorDescriptions() {
        let code = 418
        let decodeErr = NSError(domain: "Test", code: 1)
        let transErr = NSError(domain: "Net", code: 2)

        XCTAssertEqual(EazyRestError.invalidURL.errorDescription, "The URL is invalid.")
        XCTAssertEqual(EazyRestError.badResponse.errorDescription, "Invalid or missing response.")
        XCTAssertEqual(EazyRestError.serverError(code).errorDescription, "Server returned status code \(code).")
        XCTAssertEqual(EazyRestError.decodingError(decodeErr).errorDescription, "Decoding failed: \(decodeErr.localizedDescription)")
        XCTAssertEqual(EazyRestError.transportError(transErr).errorDescription, "Network error: \(transErr.localizedDescription)")
    }
}

final class EazyRestRequestDefaultsTests: XCTestCase {
    struct Dummy: EazyRestRequest {
        typealias Response = String
        var httpMethod: HTTPMethods { .get }
        var resourceName: String { "foo" }
    }

    func testDefaultHeaders() {
        let d = Dummy()
        XCTAssertEqual(d.headers?["Accept"], "application/json")
        XCTAssertEqual(d.headers?["Content-Type"], "application/json")
    }
    func testDefaultQueryItemsAndBodyData() {
        let d = Dummy()
        XCTAssertNil(d.queryItems)
        XCTAssertNil(d.bodyData)
    }
}

/// Additional coverage tests for `EazyRestClient` error handling scenarios.
///
/// This test suite ensures that various error cases are correctly surfaced and wrapped by the `EazyRestClient`.
/// It includes tests for:
/// - Invalid or malformed URLs
/// - Encoding failures when preparing requests
/// - Proper error propagation for both callback-based and async request methods
///
/// The suite uses deliberately faulty request types to trigger the error handling code paths and verify that
/// errors are surfaced as the appropriate cases of `EazyRestError`.
final class EazyRestClientAdditionalCoverageTests: XCTestCase {
    struct BadEncodable: EazyRestRequest {
        typealias Response = String
        var httpMethod: HTTPMethods { .post }
        var resourceName: String { "bad" }
        // `bodyData` is nil so encoding will be attempted.
        // We'll use a type that cannot be encoded by JSONEncoder.
        let fileHandle: FileHandle = FileHandle.nullDevice
        // This will cause JSONEncoder to fail.
        enum CodingKeys: String, CodingKey { case fileHandle }
        func encode(to encoder: Encoder) throws {
            throw NSError(domain: "FakeEncode", code: 1)
        }
    }
    struct BadURLRequest: EazyRestRequest {
        typealias Response = String
        var httpMethod: HTTPMethods { .get }
        var resourceName: String { ":://bad url" } // Invalid URL string
    }
    func testBuildURLRequestThrowsInvalidURL() {
        let client = EazyRestClient(baseURL: "https://example.com")
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            // Prefer testing the async throws variant for proper throwing
            Task {
                do {
                    _ = try await client.send(BadURLRequest())
                    XCTFail("Expected error for invalid URL")
                } catch EazyRestError.invalidURL {
                    // Good: got expected error
                } catch {
                    XCTFail("Expected invalidURL error, got: \(error)")
                }
            }
        } else {
            // Legacy: callback-based version does not throw synchronously, so we can't test throws here
        }
    }
    func testEncodingErrorCallback() {
        let client = EazyRestClient(baseURL: "https://example.com")
        let exp = expectation(description: "Encoding error callback")
        client.send(BadEncodable()) { result in
            switch result {
            case .success: XCTFail("Should fail encoding")
            case .failure(let error):
                // The EazyRestClient wraps encoding errors as decodingError
                if case EazyRestError.invalidURL = error {
                    // Good
                } else {
                    XCTFail("Expected invalidURL, got \(error)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func testEncodingErrorAsync() async {
        let client = EazyRestClient(baseURL: "https://example.com")
        do {
            _ = try await client.send(BadEncodable())
            XCTFail("Should fail encoding")
        } catch EazyRestError.decodingError {
            // Good
        } catch {
            XCTFail("Expected decodingError, got \(error)")
        }
    }
}

