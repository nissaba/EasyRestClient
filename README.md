# RestEasyAPI

![SwiftPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2014%20%7C%20macOS%2011-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Tests](https://github.com/pbeaulac/RestEasyAPI/actions/workflows/tests.yml/badge.svg)
![Release](https://img.shields.io/github/v/release/pbeaulac/RestEasyAPI)


A lightweight, protocol-oriented Swift networking layer for making REST API calls.

## Features

- Protocol-based request system
- Codable support for decoding responses
- Customizable HTTP headers
- Query parameters, body data, and binary support
- Optional authorization token
- URLSession-based implementation
- Swift Package Manager compatible

## Installation

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/nissaba/RestEasyAPI.git", from: "1.0.0")
```

Then add `RestEasyAPI` as a dependency in your target.

## Usage

### 1. Initialize the Client

```swift
import RestEasyAPI

let apiClient = RestEasy(baseUrl: "https://api.sunrise-sunset.org/")
apiClient.authToken = "Bearer your_token_if_needed"
```

### 2. Create a Request

```swift
struct MyRequest: RestEasyRequest {
    typealias Response = MyResponseModel

    var httpMethod: HTTPMethods { .get }
    var resourceName: String { "endpoint" }

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "key", value: "value")]
    }
}
```

### 3. Handle the Response

```swift
apiClient.send(MyRequest()) { result in
    switch result {
    case .success(let response):
        print("Response: \(response)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Custom and Default Headers

By default, all requests include the following headers:

```http
Accept: application/json
Content-Type: application/json
```

These are defined via a protocol extension on `RestEasyRequest`. You can override them per request if needed:

```swift
public extension RestEasyRequest {
    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
```

#### Overriding headers in a specific request:

```swift
struct AuthenticatedRequest: RestEasyRequest {
    typealias Response = MyResponse

    var httpMethod: HTTPMethods { .get }
    var resourceName: String { "secure/endpoint" }

    var headers: [String: String]? {
        [
            "Authorization": "Bearer \(myToken)"
        ]
    }
}
```

## License

MIT License. © 2025 Pascale Beaulac
