//
//  NavigationViewModel.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit
import CoreLocation

@Observable
class NavigationViewModel: NSObject {
    // MARK: - Properties
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Navigation Properties
    var showWalkSummary: Bool = false
    
    // MARK: - Map Properties
    var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // 東京駅
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // ズーム可能な適切な範囲
    )
    var currentLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D] = []
    
    // MARK: - Navigation Info Properties
    var remainingTime: String = "残り32分"
    var remainingDistance: String = "1.8km"
    var currentLocationName: String = "商店街入口付近"
    var currentStoryText: String = "物語が始まります..."
    
    // MARK: - Route Steps Properties
    var routeSteps: [RouteStep] = []
    var currentProposalId: String?
    var currentDestination: Location?
    var currentMode: WalkMode = .destination
    var visitedPois: [VisitedPoi] = []
    
    // MARK: - Services
    private let locationManager = CLLocationManager()
    private let routeService = RouteService.shared
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        setupSampleData()
    }
    
    // MARK: - Methods
    @MainActor
    func startNavigation() async {
        isLoading = true
        defer { isLoading = false }
        
        print("ナビゲーションを開始します")
        
        // 位置情報の取得を開始
        requestLocationPermission()
        
        // サンプルルートの生成
        generateSampleRoute()
    }
    
    func finishWalk() {
        print("散歩を終了します")
        showWalkSummary = true
    }
    
    @MainActor
    func recalculateRoute() async {
        guard let proposalId = currentProposalId,
              let currentLoc = currentLocation else {
            print("❌ ルート再計算に必要な情報が不足しています")
            return
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("🔄 ルート再計算開始")
            print("提案ID: \(proposalId)")
            print("現在地: \(currentLoc)")
            print("目的地: \(currentDestination?.latitude ?? 0), \(currentDestination?.longitude ?? 0)")
            
            let currentLocationData = Location(
                latitude: currentLoc.latitude,
                longitude: currentLoc.longitude
            )
            
            let response = try await routeService.recalculateRoute(
                proposalId: proposalId,
                currentLocation: currentLocationData,
                destinationLocation: currentDestination,
                mode: currentMode,
                visitedPois: visitedPois,
                weather: "sunny", // TODO: 実際の天気を取得
                timeOfDay: "afternoon" // TODO: 実際の時間帯を取得
            )
            
            // 新しいルート情報で更新
            updateRouteFromRecalculation(response)
            
            print("✅ ルート再計算成功")
            
        } catch {
            print("❌ ルート再計算に失敗しました: \(error)")
            errorMessage = "新しいルートの計算に失敗しました"
        }
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func generateSampleRoute() {
        // サンプルルート座標を生成
        let startLocation = CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
        let endLocation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.6553)
        
        route = [
            startLocation,
            CLLocationCoordinate2D(latitude: 35.6772, longitude: 139.6513),
            CLLocationCoordinate2D(latitude: 35.6792, longitude: 139.6533),
            endLocation
        ]
        
        currentLocation = startLocation
    }
    
    private func setupSampleData() {
        routeSteps = [
            RouteStep(
                stepNumber: 1,
                description: "商店街入口へ向かう",
                distance: "200m",
                isCompleted: true,
                stepType: .completed
            ),
            RouteStep(
                stepNumber: 2,
                description: "老舗和菓子店「豊月堂」を発見",
                distance: "150m",
                isCompleted: false,
                stepType: .current
            ),
            RouteStep(
                stepNumber: 3,
                description: "昭和レトロ喫茶「黄昏」で休憩",
                distance: "300m",
                isCompleted: false,
                stepType: .upcoming
            ),
            RouteStep(
                stepNumber: 4,
                description: "手作り雑貨店で宝物探し",
                distance: "250m",
                isCompleted: false,
                stepType: .upcoming
            )
        ]
    }
    
    private func updateCurrentLocationInfo() {
        // 現在地の情報を更新
        currentLocationName = "商店街入口付近"
        currentStoryText = "背景の蜜蜂が紡ぐ、古き良き商店街の物語"
    }
    
    private func updateRouteFromRecalculation(_ response: RouteRecalculateResponse) {
        // 再計算されたルート情報でViewModelを更新
        let newRoute = response.updatedRoute
        
        // TODO: routePolylineから実際の座標配列を生成する実装が必要
        // 現在はサンプル座標を使用
        generateSampleRoute()
        
        // 残り時間と距離を更新
        remainingTime = "残り\(newRoute.estimatedDurationMinutes)分"
        remainingDistance = String(format: "%.1fkm", Double(newRoute.estimatedDistanceMeters) / 1000.0)
        
        // ストーリーテキストを更新
        currentStoryText = newRoute.generatedStory
        
        // ハイライト情報を使って新しいルートステップを生成
        routeSteps = newRoute.highlights.enumerated().map { index, highlight in
            RouteStep(
                stepNumber: index + 1,
                description: highlight,
                distance: "\(200 + index * 150)m", // サンプル距離
                isCompleted: false,
                stepType: index == 0 ? .current : .upcoming
            )
        }
        
        print("📍 ルート情報を更新しました:")
        print("   - タイトル: \(newRoute.title)")
        print("   - 推定時間: \(newRoute.estimatedDurationMinutes)分")
        print("   - 推定距離: \(newRoute.estimatedDistanceMeters)m")
        print("   - ハイライト数: \(newRoute.highlights.count)")
    }
    
    func setSelectedRoute(_ route: StoryRoute) {
        // 選択されたルートの情報を保存
        currentProposalId = route.id
        // TODO: StoryRouteからLocationを取得する方法を実装
        currentDestination = nil // 実際の実装では適切な値を設定
        currentMode = .destination
        
        print("📍 選択されたルート情報を保存:")
        print("   - ID: \(route.id)")
        print("   - タイトル: \(route.title)")
    }
}

// MARK: - CLLocationManagerDelegate
extension NavigationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        mapRegion.center = location.coordinate
        
        updateCurrentLocationInfo()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("位置情報の許可が拒否されました")
            errorMessage = "位置情報の許可が必要です"
        default:
            break
        }
    }
}

// MARK: - Supporting Types
struct RouteStep {
    let stepNumber: Int
    let description: String
    let distance: String
    let isCompleted: Bool
    let stepType: RouteStepType
}

enum RouteStepType {
    case completed
    case current
    case upcoming
}