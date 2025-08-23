import Foundation

struct WalksResponse: ResponseProtocol {
    let walks: [Walk]
}

struct Walk: Codable {
    let id: String
    let title: String
    let areaName: String
    let date: String
    let summary: String
    let durationMinutes: Int
    let distanceMeters: Int
    let tags: [String]
    let endLocation: WalkLocation
    let routePolyline: String
}

struct WalkLocation: Codable {
    let latitude: Double
    let longitude: Double
}
