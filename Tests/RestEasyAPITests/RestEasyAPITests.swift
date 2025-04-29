//
//  RestEasyAPITests.swift
//  RestEasyAPI
//
//  Created by Pascale on 2025-04-29.
//


import XCTest
@testable import EasyRestClient

struct DummyRequest: EasyResRequest {
    typealias Response = String
    
    var httpMethod: HTTPMethods { .get }
    var resourceName: String { "test" }

    // propriétés ajoutées pour satisfaire le protocole
    var queryItems: [URLQueryItem]? { nil }
    var bodyData: Data? { nil }
}

final class RestEasyAPITests: XCTestCase {

    func testHeadersDebug() {
        let req = DummyRequest()
        print("Headers:", req.headers ?? [:])
    }

    func testHeadersIsNotNil() {
        let req = DummyRequest()
        XCTAssertNotNil(req.headers)
    }
    
    func testDefaultHeaders() {
        let req = DummyRequest()
        XCTAssertEqual(req.headers?["Accept"], "application/json")
    }
    

}

