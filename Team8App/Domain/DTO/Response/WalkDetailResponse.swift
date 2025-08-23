import Foundation

struct WalkDetailResponse: ResponseProtocol {
    let id: String
    let title: String
    let areaName: String
    let date: String
    let description: String
    let theme: String
    let durationMinutes: Int
    let distanceMeters: Int
    let routePolyline: String
    let tags: [String]
    let navigationSteps: [WalkNavigationStep]
}

struct WalkNavigationStep: Codable {
    let type: String
    let name: String
    let description: String
    let distanceToNextMeters: Int
    let latitude: Double
    let longitude: Double
}
