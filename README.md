# RestEasy

[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://github.com/nissaba/RestEasy)

**RestEasy** is a lightweight, flexible, protocol-oriented Swift framework for interacting with REST APIs easily.

Created and maintained by **Pascale Beaulac**.  
Licensed under the **MIT License**.

---

## ✨ Features

- Protocol-oriented request/response design
- Decodable responses using Swift's `Decodable`
- Full control over:
  - HTTP method
  - Headers
  - Query parameters
  - Body data
- Supports:
  - JSON APIs
  - Binary uploads (e.g., file uploads)
  - Raw data downloads
- Minimal runtime code
- Clean Swift 5.9+ codebase
- No external dependencies

---

## 🛠 Installation

### Swift Package Manager (SPM)

Add RestEasy to your `Package.swift`:

```swift
.package(url: "https://github.com/nissaba/RestEasy.git", from: "1.0.0"),
```

Or via Xcode:
- Go to `File > Add Packages`
- Enter:

```
https://github.com/nissaba/RestEasy.git
```

---

## 📚 Usage

### 1. Initialize the Client

```swift
import RestEasy

let apiClient = RestEasy(token: "your_auth_token", baseUrl: "https://api.example.com/")
```

---

### 2. Define Your Requests

#### Simple GET Request:

```swift
struct GetUserProfileRequest: RestEasyRequest {
    typealias Response = UserProfile

    var httpMethod: HTTPMethods { .get }
    var resourceName: String { "user/profile" }
}
```

---

#### GET Request with Query Parameters:

```swift
struct SearchActivitiesRequest: RestEasyRequest {
    typealias Response = [Activity]

    let userId: Int
    let status: String

    var httpMethod: HTTPMethods { .get }
    var resourceName: String { "activities" }

    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "userId", value: "\(userId)"),
            URLQueryItem(name: "status", value: status)
        ]
    }
}
```

---

#### Binary Upload (Data Upload Request):

```swift
struct UploadRideDataRequest: RestEasyRequest {
    typealias Response = RestEasyDefaultResponse

    let data: Data
    let location: String

    var httpMethod: HTTPMethods { .put }
    var resourceName: String { location }

    var headers: [String: String]? {
        [
            "Content-Type": "application/octet-stream"
        ]
    }

    var bodyData: Data? {
        data
    }
}
```

---

### 3. Send the Request

```swift
let request = GetUserProfileRequest()

apiClient.send(request) { result in
    switch result {
    case .success(let profile):
        print("Loaded profile:", profile)
    case .failure(let error):
        print("Request failed with error:", error)
    }
}
```

---

## 📖 RestEasyRequest - What You Define

| Property | Purpose |
|:---------|:--------|
| `httpMethod` | HTTP method (GET, POST, PUT, DELETE) |
| `resourceName` | Relative URL path |
| `headers` | Optional custom headers |
| `queryItems` | Optional query parameters (GET, DELETE) |
| `bodyData` | Optional body data for raw uploads |

---

## 📦 Project Structure

| File | Purpose |
|:-----|:--------|
| `RestEasy.swift` | Main API client |
| `RestEasyRequest.swift` | Request protocol |
| `RestEasyError.swift` | Common error types |
| `RestEasyResponse.swift` | Decodable server response with `data` field |
| `RestEasyDefaultResponse.swift` | Server response without `data` field |
| `Decodable+RestEasy.swift` | Utility to simplify decoding |

---

## 📜 License

This project is licensed under the [MIT License](./LICENSE).

---
