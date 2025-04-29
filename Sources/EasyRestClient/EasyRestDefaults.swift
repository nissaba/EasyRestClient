//
//  EasyResRequest.swift
//  RestEasyAPI
//
//  Created by Pascale on 2025-04-29.
//

public extension EasyResRequest {
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
