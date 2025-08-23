import Foundation

struct RouteProposalResponse: ResponseProtocol {
    let proposals: [RouteProposal]
}

struct RouteProposal: Codable {
    let proposalId: String?  // 一時的にオプショナルに変更
    let title: String
    let estimatedDurationMinutes: Int?  // オプショナルに変更
    let estimatedDistanceMeters: Int?   // オプショナルに変更
    let theme: String?  // オプショナルに変更
    let displayHighlights: [String]?  // オプショナルに変更
    let navigationSteps: [NavigationStep]?  // オプショナルに変更
    let routePolyline: String?  // オプショナルに変更
    let generatedStory: String?  // オプショナルに変更
    
}

struct NavigationStep: Codable {
    let type: NavigationStepType
    let description: String
    let distanceToNextMeters: Int
    let poiId: String?
    let name: String?
    let latitude: Double?
    let longitude: Double?
    
}

enum NavigationStepType: String, Codable {
    case navigation = "navigation"
    case poi = "poi"
}

