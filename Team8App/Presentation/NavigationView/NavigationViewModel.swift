//
//  NavigationViewModel.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

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
    
    var remainingTime: String = "残り32分"
    var remainingDistance: String = "1.8km"
    var currentStoryText: String = "物語が始まります..."
    var routeTitle: String = "ナビゲーション中"
    
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
        loadSavedRoute()
    }
    
    // MARK: - Methods
    @MainActor
    func startNavigation() async {
        isLoading = true
        defer { isLoading = false }
        
        print("ナビゲーションを開始します")
        
        // 位置情報の取得を開始
        requestLocationPermission()
    }
    
    func finishWalk() {
        print("散歩を終了します")
        clearSavedRoute() // 散歩終了時にルート情報をクリア
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
            

            // TODO: 実際の現在地を取得する方法を実装
            let mockcurrentLocation = Location(
                latitude: 34.97544,
                longitude: 135.76029
            )

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
            print("📱 API レスポンス詳細:")
            print("   - 新タイトル: \(response.updatedRoute.title)")
            print("   - 推定時間: \(response.updatedRoute.estimatedDurationMinutes)分")
            print("   - 推定距離: \(response.updatedRoute.estimatedDistanceMeters)m")
            print("   - ハイライト: \(response.updatedRoute.highlights.joined(separator: ", "))")
            print("   - ストーリー: \(response.updatedRoute.generatedStory)")

            currentStoryText = response.updatedRoute.generatedStory
            
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
    
    private func updateRouteFromRecalculation(_ response: RouteRecalculateResponse) {
        // 再計算されたルート情報でViewModelを更新
        let newRoute = response.updatedRoute
        
        // TODO: routePolylineから実際の座標配列を生成する実装が必要
        // 現在はサンプル座標を使用（将来的にはroutePolylineをパースして座標配列に変換）
        
        // 残り時間と距離を更新（APIからの実際の値を使用）
        remainingTime = "残り\(newRoute.estimatedDurationMinutes)分"
        remainingDistance = String(format: "%.1fkm", Double(newRoute.estimatedDistanceMeters) / 1000.0)
        
        // ストーリーテキストを更新
        currentStoryText = newRoute.generatedStory
        
        // ハイライト情報を使って新しいルートステップを生成
        routeSteps = newRoute.highlights.enumerated().map { index, highlight in
            let distance = calculateStepDistance(for: index, totalDistance: newRoute.estimatedDistanceMeters)
            return RouteStep(
                stepNumber: index + 1,
                description: highlight,
                distance: distance,
                isCompleted: false,
                stepType: index == 0 ? .current : .upcoming
            )
        }
        
        print("📍 ルート情報をAPIレスポンスで更新しました:")
        print("   - タイトル: \(newRoute.title)")
        print("   - 推定時間: \(newRoute.estimatedDurationMinutes)分")
        print("   - 推定距離: \(newRoute.estimatedDistanceMeters)m")
        print("   - ハイライト数: \(newRoute.highlights.count)")
        print("   - ストーリー長: \(newRoute.generatedStory.count)文字")
        print("   - ルートステップ数: \(routeSteps.count)")
    }
    
    private func calculateStepDistance(for index: Int, totalDistance: Int) -> String {
        // ハイライト間の距離を計算（総距離をハイライト数で分割）
        let stepCount = max(routeSteps.count, 1)
        let averageDistance = Double(totalDistance) / Double(stepCount)
        let stepDistance = Int(averageDistance * (0.8 + Double(index) * 0.1)) // バリエーションを追加
        return "\(stepDistance)m"
    }
    
    func setSelectedRoute(_ route: StoryRoute) {
        // 選択されたルートの情報を保存
        currentProposalId = route.id
        // TODO: StoryRouteからLocationを取得する方法を実装
        currentDestination = nil // 実際の実装では適切な値を設定
        currentMode = .destination
        
        // ルートタイトルを設定
        routeTitle = route.title
        
        // UserDefaultsに保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(route.id, forKey: "currentProposalId")
        userDefaults.set(route.title, forKey: "currentRouteTitle")
        userDefaults.set(route.duration, forKey: "currentRouteDuration")
        userDefaults.set(route.distance, forKey: "currentRouteDistance")
        userDefaults.set(route.description, forKey: "currentRouteDescription")
        
        // WalkModeを文字列として保存
        userDefaults.set("destination", forKey: "currentWalkMode")
        
        // 保存を確実に実行
        userDefaults.synchronize()
        
        print("📍 選択されたルート情報を保存:")
        print("   - ID: \(route.id)")
        print("   - タイトル: \(route.title)")
        print("   - 時間: \(route.duration)分")
        print("   - 距離: \(route.distance)km")
        print("💾 UserDefaultsに保存完了")
    }
    
    func loadSavedRoute() {
        // UserDefaultsから保存されたルート情報を復元
        let userDefaults = UserDefaults.standard
        
        if let savedProposalId = userDefaults.string(forKey: "currentProposalId") {
            currentProposalId = savedProposalId
            
            // 基本情報を復元
            let savedTitle = userDefaults.string(forKey: "currentRouteTitle") ?? ""
            let savedDuration = userDefaults.integer(forKey: "currentRouteDuration")
            let savedDistance = userDefaults.double(forKey: "currentRouteDistance")
            let savedDescription = userDefaults.string(forKey: "currentRouteDescription") ?? ""
            let savedMode = userDefaults.string(forKey: "currentWalkMode") ?? "destination"
            
            // ルートタイトルを設定
            routeTitle = savedTitle.isEmpty ? "ナビゲーション中" : savedTitle
            
            // 実際のAPIデータを復元
            let actualDuration = userDefaults.object(forKey: "currentRouteActualDuration") as? Int
            let actualDistance = userDefaults.object(forKey: "currentRouteActualDistance") as? Int
            let savedStory = userDefaults.string(forKey: "currentRouteStory")
            
            // ナビゲーションステップを復元
            if let stepsData = userDefaults.data(forKey: "currentRouteNavigationSteps"),
               let navigationSteps = try? JSONDecoder().decode([NavigationStep].self, from: stepsData) {
                loadNavigationStepsFromAPI(navigationSteps, actualDuration: actualDuration)
            }
            
            // ストーリーを復元
            if let story = savedStory {
                currentStoryText = story
            }
            
            // 実際の時間と距離を表示
            if let duration = actualDuration {
                remainingTime = "\(duration)分"
            }
            if let distance = actualDistance {
                remainingDistance = String(format: "%.1fkm", Double(distance) / 1000.0)
            }
            
            // WalkModeを復元
            currentMode = savedMode == "timeBased" ? .timeBased : .destination
            
            print("📱 UserDefaultsから実際のAPIデータを復元:")
            print("   - ID: \(savedProposalId)")
            print("   - タイトル: \(savedTitle)")
            print("   - 実際の時間: \(actualDuration ?? 0)分")
            print("   - 実際の距離: \(actualDistance ?? 0)m")
            print("   - ストーリー: \(savedStory != nil ? "復元完了" : "なし")")
            print("   - ナビゲーションステップ: 復元完了")
        } else {
            print("📱 保存されたルート情報が見つかりませんでした")
        }
    }
    
    private func loadNavigationStepsFromAPI(_ steps: [NavigationStep], actualDuration: Int?) {
        // APIのNavigationStepからRouteStepに変換
        self.routeSteps = steps.enumerated().map { index, step in
            RouteStep(
                stepNumber: index + 1,
                description: step.description,
                distance: "\(step.distanceToNextMeters)m",
                isCompleted: false,
                stepType: index == 0 ? .current : .upcoming
            )
        }
        
        print("📍 APIからのナビゲーションステップを復元: \(steps.count)個")
    }
    
    func clearSavedRoute() {
        // UserDefaultsから保存されたルート情報を削除
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "currentProposalId")
        userDefaults.removeObject(forKey: "currentRouteTitle")
        userDefaults.removeObject(forKey: "currentRouteDuration")
        userDefaults.removeObject(forKey: "currentRouteDistance")
        userDefaults.removeObject(forKey: "currentRouteDescription")
        userDefaults.removeObject(forKey: "currentWalkMode")
        
        // 実際のAPIデータのキーも削除
        userDefaults.removeObject(forKey: "currentRouteHighlights")
        userDefaults.removeObject(forKey: "currentRouteNavigationSteps")
        userDefaults.removeObject(forKey: "currentRouteStory")
        userDefaults.removeObject(forKey: "currentRoutePolyline")
        userDefaults.removeObject(forKey: "currentRouteActualDuration")
        userDefaults.removeObject(forKey: "currentRouteActualDistance")
        
        userDefaults.synchronize()
        
        print("🗑 UserDefaultsから実際のAPIデータを含む全ルート情報を削除しました")
    }
}

// MARK: - CLLocationManagerDelegate
extension NavigationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        mapRegion.center = location.coordinate
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
