//
//  RouteRepository.swift
//  Team8App
//
//  Created by AI Assistant on 2025/01/27.
//

import Foundation
import Alamofire

class RouteRepository: RouteRepositoryProtocol {
    private let apiClient = APIClient.shared
    static let shared = RouteRepository()
    
    private init() {}
    
    func generateRouteProposals(request: RouteProposalRequest) async throws -> RouteProposalResponse {
        let apiRequest = GenerateRouteProposalsRequest(routeProposalRequest: request)
        let response = try await apiClient.call(request: apiRequest)
        return response
    }
    
    func recalculateRoute(request: RouteRecalculateRequest) async throws -> RouteRecalculateResponse {
        let apiRequest = RecalculateRouteRequest(routeRecalculateRequest: request)
        let response = try await apiClient.call(request: apiRequest)
        return response
    }
}

