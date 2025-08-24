//
//  WalkRepository.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/24.
//

import Foundation
import Alamofire

class WalkRepository: WalkRepositoryProtocol {
    private let apiClient = APIClient.shared
    static let shared = WalkRepository()
    
    private init() {}
    
    func getWalks(bbox: String?) async throws -> WalksResponse {
        let apiRequest = GetWalksRequest(bbox: bbox)
        let response = try await apiClient.call(request: apiRequest)
        return response
    }
    
    func getWalkDetail(walkId: String) async throws -> WalkDetailResponse {
        let apiRequest = GetWalkDetailRequest(walkId: walkId)
        let response = try await apiClient.call(request: apiRequest)
        return response
    }
}
