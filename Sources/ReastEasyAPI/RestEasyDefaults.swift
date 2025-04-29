//
//  RestEasyDefaults.swift
//  RestEasyAPI
//
//  Created by Pascale on 2025-04-29.
//

public extension RestEasyRequest {
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
