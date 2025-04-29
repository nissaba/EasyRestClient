//
//  SunriseSunsetResponse.swift
//  ExampleApp
//
//  Created by Pascale on 2025-04-28.
//


import Foundation

/// Decodable response from Sunrise-Sunset API
struct SunriseSunsetResponse: Decodable {
    let results: Results
    let status: String
    
    struct Results: Decodable {
        let sunrise: String
        let sunset: String
        let solar_noon: String
        let day_length: String
    }
}
