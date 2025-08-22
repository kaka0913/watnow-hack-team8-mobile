//
//  RouteRepositoryProtocol.swift
//  Team8App
//
//  Created by 株丹優一郎 on 2025/08/22.
//

import Foundation

protocol RouteRepositoryProtocol {
    /// ルート提案の生成
    func generateRouteProposals(request: RouteProposalRequest) async throws -> RouteProposalResponse
    
    /// ルートの再計算
    func recalculateRoute(request: RouteRecalculateRequest) async throws -> RouteRecalculateResponse
}
