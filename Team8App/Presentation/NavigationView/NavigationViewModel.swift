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
    var showRouteUpdateCompleteDialog: Bool = false
    
    // MARK: - Navigation Properties
    var showWalkSummary: Bool = false
    
    // MARK: - Map Properties
    var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), // 東京駅
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // ズーム可能な適切な範囲
    )
    var currentLocation: CLLocationCoordinate2D?
    var route: [CLLocationCoordinate2D] = []
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var annotations: [CustomAnnotation] = []
    
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
    
    // MARK: - Route Deviation Properties
    var showRouteDeviationDialog: Bool = false
    private let routeDeviationThreshold: Double = 150.0 // 250m
    private var isTrackingRoute: Bool = false
    private var hasUserDismissedDeviationDialog: Bool = false // ユーザーがダイアログを閉じたかのフラグ
    
    // MARK: - Services
    private let locationManager = CLLocationManager()
    private let routeService = RouteService.shared
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        loadSavedRoute()
        startRouteTracking()
    }
    
    // MARK: - Methods
    @MainActor
    func startNavigation() async {
        isLoading = true
        defer { isLoading = false }
        
        print("ナビゲーションを開始します")
        
        // 位置情報の取得を開始
        requestLocationPermission()
        
        // ルート追跡を開始
        isTrackingRoute = true
        startRouteTracking()
    }
    
    func finishWalk() {
        print("散歩を終了します")
        isTrackingRoute = false
        LocationManager.shared.stopLocationUpdates()
        // clearSavedRoute()をコメントアウト - WalkSummaryViewで必要な場合があるため
        // clearSavedRoute() // 散歩終了時にルート情報をクリア
        showWalkSummary = true
    }
    
    // ダイアログが閉じられた時に呼び出されるメソッド
    func dismissRouteDeviationDialog() {
        showRouteDeviationDialog = false
        hasUserDismissedDeviationDialog = true
        print("🚫 ルート逸脱ダイアログが閉じられました。自動表示を無効化します。")
    }
    
    @MainActor
    func recalculateRoute() async {
        print("🔍 ルート再計算前の状態確認:")
        print("   - currentProposalId: \(currentProposalId ?? "nil")")
        print("   - currentDestination: \(currentDestination?.latitude ?? 0), \(currentDestination?.longitude ?? 0)")
        
        // currentProposalIdの取得またはUserDefaultsからの復元
        let proposalId: String
        if let currentId = currentProposalId {
            proposalId = currentId
        } else {
            print("❌ currentProposalIdが設定されていません")
            // UserDefaultsから再取得を試行
            if let savedProposalId = UserDefaults.standard.string(forKey: "currentProposalId") {
                print("🔄 UserDefaultsからproposalIdを復元: \(savedProposalId)")
                currentProposalId = savedProposalId
                proposalId = savedProposalId
            } else {
                print("❌ UserDefaultsからもproposalIdが見つかりません")
                errorMessage = "ルート情報が見つかりません。再度ルート選択してください。"
                return
            }
        }
        
        // 現在地が取得できていない場合は、LocationManagerから取得を試行
        let currentLoc: CLLocationCoordinate2D
        if let location = currentLocation {
            currentLoc = location
        } else {
            print("⚠️ 現在地が取得できていないため、LocationManagerから取得を試行")
            // LocationManagerから現在地を取得
            let realLocation = await LocationManager.shared.getCurrentLocation()
            currentLoc = realLocation
            currentLocation = realLocation
        }
        
        isLoading = true
        errorMessage = nil
        showRouteUpdateCompleteDialog = false
        
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
                weather: "sunny",
                timeOfDay: "afternoon"
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
            
            // 完了ダイアログを表示
            showRouteUpdateCompleteDialog = true
            
        } catch {
            print("❌ ルート再計算に失敗しました: \(error)")
            errorMessage = "新しいルートの計算に失敗しました"
        }
        
        isLoading = false
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
        
        // ポリラインをデコードして座標配列に変換
        let decodedRoute = PolylineDecoder.decode(newRoute.routePolyline)
        if PolylineDecoder.isValidCoordinates(decodedRoute) {
            route = decodedRoute
            routeCoordinates = decodedRoute
            
            // アノテーションを更新
            updateAnnotations(for: decodedRoute)
            
            // 地図の表示領域をルートに合わせて調整
            if let newRegion = PolylineDecoder.calculateMapRegion(from: decodedRoute) {
                mapRegion = newRegion
            }
            
            print("🗺 ポリラインから\(decodedRoute.count)個の座標を生成しました")
        } else {
            print("⚠️ ポリラインのデコードに失敗したため、既存のルートを維持します")
        }
        
        // ルートタイトルを更新（再計算後の新しいタイトル）
        routeTitle = newRoute.title
        
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
        
        // UserDefaultsにも更新された情報を保存
        updateUserDefaultsWithRecalculatedRoute(newRoute)
        
        print("📍 ルート情報をAPIレスポンスで更新しました:")
        print("   - 新タイトル: \(newRoute.title)")
        print("   - 推定時間: \(newRoute.estimatedDurationMinutes)分")
        print("   - 推定距離: \(newRoute.estimatedDistanceMeters)m")
        print("   - ハイライト数: \(newRoute.highlights.count)")
        print("   - ストーリー長: \(newRoute.generatedStory.count)文字")
        print("   - ルートステップ数: \(routeSteps.count)")
        print("   - ポリライン座標数: \(route.count)")
        print("✨ NavigationView UI更新完了")
    }
    
    private func updateUserDefaultsWithRecalculatedRoute(_ route: UpdatedRoute) {
        // 再計算されたルート情報をUserDefaultsに保存
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(route.title, forKey: "currentRouteTitle")
        userDefaults.set(route.estimatedDurationMinutes, forKey: "currentRouteActualDuration")
        userDefaults.set(route.estimatedDistanceMeters, forKey: "currentRouteActualDistance")
        userDefaults.set(route.generatedStory, forKey: "currentRouteStory")
        userDefaults.set(route.routePolyline, forKey: "currentRoutePolyline")
        
        // ハイライトを保存
        let highlightsData = try? JSONEncoder().encode(route.highlights)
        userDefaults.set(highlightsData, forKey: "currentRouteHighlights")
        
        userDefaults.synchronize()
        
        print("💾 再計算されたルート情報をUserDefaultsに保存完了")
    }
    
    private func calculateStepDistance(for index: Int, totalDistance: Int) -> String {
        // ハイライト間の距離を計算（総距離をハイライト数で分割）
        let stepCount = max(routeSteps.count, 1)
        let averageDistance = Double(totalDistance) / Double(stepCount)
        let stepDistance = Int(averageDistance * (0.8 + Double(index) * 0.1)) // バリエーションを追加
        return "\(stepDistance)m"
    }
    
    func setSelectedRoute(_ route: StoryRoute) {
        print("🔄 NavigationViewModel.setSelectedRoute() 開始")
        print("📋 受信したルート情報:")
        print("   - ID: \(route.id)")
        print("   - Title: \(route.title)")
        print("   - Duration: \(route.duration)分")
        print("   - Distance: \(route.distance)km")
        print("   - Description: \(route.description)")
        print("   - RoutePolyline: \(route.routePolyline ?? "nil")")
        
        // 選択されたルートの情報を保存
        currentProposalId = route.id
        
        // DestinationSettingViewModelから目的地座標を復元
        // （DestinationSettingViewModelで使用された座標と同じ値を使用）
        currentMode = .destination
        // ルートタイトルを設定
        routeTitle = route.title
        
        // ルート自体のポリライン情報があれば直接使用
        if let routePolyline = route.routePolyline, !routePolyline.isEmpty {
            print("📍 StoryRouteからポリライン直接使用:")
            print("   - ポリライン文字列長: \(routePolyline.count)")
            print("   - ポリライン先頭20文字: \(String(routePolyline.prefix(20)))")


            let decodedRoute = PolylineDecoder.decode(routePolyline)
            print("🔍 PolylineDecoder結果: \(decodedRoute.count)個の座標")
            
            if PolylineDecoder.isValidCoordinates(decodedRoute) {
                self.route = decodedRoute
                self.routeCoordinates = decodedRoute
                
                print("✅ StoryRouteポリラインからルート座標設定:")
                print("   - route.count: \(self.route.count)")
                print("   - routeCoordinates.count: \(self.routeCoordinates.count)")
                if decodedRoute.count > 0 {
                    print("   - 開始座標: (\(decodedRoute[0].latitude), \(decodedRoute[0].longitude))")
                    print("   - 終了座標: (\(decodedRoute[decodedRoute.count-1].latitude), \(decodedRoute[decodedRoute.count-1].longitude))")
                }
                
                // アノテーションを設定
                updateAnnotations(for: decodedRoute)
                
                // 地図の表示領域をルートに合わせて調整
                if let newRegion = PolylineDecoder.calculateMapRegion(from: decodedRoute) {
                    mapRegion = newRegion
                    print("🗺 地図領域調整完了: center=(\(newRegion.center.latitude), \(newRegion.center.longitude))")
                }
                
                print("🗺 選択されたルートのポリラインから\(decodedRoute.count)個の座標を設定しました")
            } else {
                print("❌ StoryRouteポリラインのデコードに失敗")
            }
        } else {
            print("⚠️ StoryRouteにポリライン情報がありません")
            
            // 保存されているポリライン情報があれば復元
            if let savedPolyline = UserDefaults.standard.string(forKey: "currentRoutePolyline") {
                print("🔄 UserDefaultsからポリライン復元を試行")
                print("   - ポリライン文字列長: \(savedPolyline.count)")
                
                let decodedRoute = PolylineDecoder.decode(savedPolyline)
                if PolylineDecoder.isValidCoordinates(decodedRoute) {
                    self.route = decodedRoute
                    self.routeCoordinates = decodedRoute
                    
                    print("✅ UserDefaultsポリラインからルート座標設定:")
                    print("   - route.count: \(self.route.count)")
                    print("   - routeCoordinates.count: \(self.routeCoordinates.count)")
                    
                    // アノテーションを設定
                    updateAnnotations(for: decodedRoute)
                    
                    // 地図の表示領域をルートに合わせて調整
                    if let newRegion = PolylineDecoder.calculateMapRegion(from: decodedRoute) {
                        mapRegion = newRegion
                    }
                    
                    print("🗺 選択されたルートのポリラインから\(decodedRoute.count)個の座標を復元しました")
                } else {
                    print("❌ UserDefaultsポリラインのデコードに失敗")
                }
            } else {
                print("❌ UserDefaultsにもポリライン情報がありません")
            }
        }
        
        // 位置情報の取得を開始（recalculateRouteで現在地が必要なため）
        requestLocationPermission()
        locationManager.startUpdatingLocation()
        
        // UserDefaultsに保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(route.id, forKey: "currentProposalId")
        userDefaults.set(route.title, forKey: "currentRouteTitle")
        userDefaults.set(route.duration, forKey: "currentRouteDuration")
        userDefaults.set(route.distance, forKey: "currentRouteDistance")
        userDefaults.set(route.description, forKey: "currentRouteDescription")
        
        // ポリライン情報も保存
        if let routePolyline = route.routePolyline {
            userDefaults.set(routePolyline, forKey: "currentRoutePolyline")
            print("💾 StoryRouteのポリラインをUserDefaultsに保存")
        }
        
        // WalkModeを文字列として保存
        userDefaults.set("destination", forKey: "currentWalkMode")
        
        // 目的地座標を保存
        if let destination = currentDestination {
            userDefaults.set(destination.latitude, forKey: "currentDestinationLatitude")
            userDefaults.set(destination.longitude, forKey: "currentDestinationLongitude")
            print("💾 目的地座標をUserDefaultsに保存: (\(destination.latitude), \(destination.longitude))")
        }
        
        // 保存を確実に実行
        userDefaults.synchronize()
        
        print("📍 選択されたルート情報を保存:")
        print("   - ID: \(route.id)")
        print("   - タイトル: \(route.title)")
        print("   - 時間: \(route.duration)分")
        print("   - 距離: \(route.distance)km")
        print("💾 UserDefaultsに保存完了")
        print("✅ NavigationViewModel.setSelectedRoute() 完了")
    }
    
    func loadSavedRoute() {
        print("🔍 NavigationViewModel.loadSavedRoute() 開始")
        
        // UserDefaultsから保存されたルート情報を復元
        let userDefaults = UserDefaults.standard
        
        if let savedProposalId = userDefaults.string(forKey: "currentProposalId") {
            print("📂 UserDefaultsからproposalId復元: \(savedProposalId)")
            currentProposalId = savedProposalId
            
            // 基本情報を復元
            let savedTitle = userDefaults.string(forKey: "currentRouteTitle") ?? ""
            _ = userDefaults.integer(forKey: "currentRouteDuration")
            _ = userDefaults.double(forKey: "currentRouteDistance")
            _ = userDefaults.string(forKey: "currentRouteDescription") ?? ""
            let savedMode = userDefaults.string(forKey: "currentWalkMode") ?? "destination"
            
            print("📋 基本情報復元:")
            print("   - savedTitle: \(savedTitle)")
            print("   - savedMode: \(savedMode)")
            
            // ルートタイトルを設定
            routeTitle = savedTitle.isEmpty ? "ナビゲーション中" : savedTitle
            
            // 実際のAPIデータを復元
            let actualDuration = userDefaults.object(forKey: "currentRouteActualDuration") as? Int
            let actualDistance = userDefaults.object(forKey: "currentRouteActualDistance") as? Int
            let savedStory = userDefaults.string(forKey: "currentRouteStory")
            
            print("🌐 APIデータ復元:")
            print("   - actualDuration: \(actualDuration ?? 0)")
            print("   - actualDistance: \(actualDistance ?? 0)")
            print("   - savedStory length: \(savedStory?.count ?? 0)")
            
            // ナビゲーションステップを復元
            if let stepsData = userDefaults.data(forKey: "currentRouteNavigationSteps"),
               let navigationSteps = try? JSONDecoder().decode([NavigationStep].self, from: stepsData) {
                print("📍 ナビゲーションステップ復元: \(navigationSteps.count)個")
                loadNavigationStepsFromAPI(navigationSteps, actualDuration: actualDuration)
            } else {
                print("⚠️ ナビゲーションステップの復元に失敗")
            }
            
            // ポリラインを復元してルート座標を設定
            if let savedPolyline = userDefaults.string(forKey: "currentRoutePolyline") {
                print("🗺 UserDefaultsからポリライン復元開始")
                print("   - ポリライン文字列長: \(savedPolyline.count)")
                print("   - ポリライン先頭20文字: \(String(savedPolyline.prefix(20)))")
                
                let decodedRoute = PolylineDecoder.decode(savedPolyline)
                print("🔍 PolylineDecoder結果: \(decodedRoute.count)個の座標")
                
                if PolylineDecoder.isValidCoordinates(decodedRoute) {
                    route = decodedRoute
                    routeCoordinates = decodedRoute
                    
                    print("✅ ルート座標設定完了:")
                    print("   - route.count: \(route.count)")
                    print("   - routeCoordinates.count: \(routeCoordinates.count)")
                    if decodedRoute.count > 0 {
                        print("   - 開始座標: (\(decodedRoute[0].latitude), \(decodedRoute[0].longitude))")
                        print("   - 終了座標: (\(decodedRoute[decodedRoute.count-1].latitude), \(decodedRoute[decodedRoute.count-1].longitude))")
                    }
                    
                    // アノテーションを更新
                    updateAnnotations(for: decodedRoute)
                    
                    // 地図の表示領域をルートに合わせて調整
                    if let newRegion = PolylineDecoder.calculateMapRegion(from: decodedRoute) {
                        mapRegion = newRegion
                        print("🗺 地図領域調整完了: center=(\(newRegion.center.latitude), \(newRegion.center.longitude))")
                    }
                    
                    print("🗺 保存されたポリラインから\(decodedRoute.count)個の座標を復元しました")
                } else {
                    print("❌ 保存されたポリラインのデコードに失敗しました")
                }
            } else {
                print("⚠️ UserDefaultsにポリライン情報が見つかりません")
            }
            
            // ストーリーを復元
            if let story = savedStory {
                currentStoryText = story
                print("📖 ストーリー復元完了: \(story.count)文字")
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
            
            // 目的地座標を復元
            let destinationLat = userDefaults.double(forKey: "currentDestinationLatitude")
            let destinationLon = userDefaults.double(forKey: "currentDestinationLongitude")
            if destinationLat != 0 && destinationLon != 0 {
                currentDestination = Location(latitude: destinationLat, longitude: destinationLon)
                print("🎯 目的地座標復元: (\(destinationLat), \(destinationLon))")
            }
            
            print("📱 UserDefaultsから実際のAPIデータを復元:")
            print("   - ID: \(savedProposalId)")
            print("   - タイトル: \(savedTitle)")
            print("   - 実際の時間: \(actualDuration ?? 0)分")
            print("   - 実際の距離: \(actualDistance ?? 0)m")
            print("   - ストーリー: \(savedStory != nil ? "復元完了" : "なし")")
            print("   - ナビゲーションステップ: 復元完了")
            print("   - ポリライン座標数: \(route.count)")
        } else {
            print("📱 保存されたルート情報が見つかりませんでした")
        }
        
        print("✅ NavigationViewModel.loadSavedRoute() 完了")
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
        
        // 目的地座標も削除
        userDefaults.removeObject(forKey: "currentDestinationLatitude")
        userDefaults.removeObject(forKey: "currentDestinationLongitude")
        
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
        
        // ルート逸脱チェックを実行
        checkRouteDeviation()
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

// MARK: - Private Helper Methods
extension NavigationViewModel {
    private func updateAnnotations(for coordinates: [CLLocationCoordinate2D]) {
        annotations.removeAll()
        
        guard !coordinates.isEmpty else { return }
        
        // 開始地点のアノテーション
        if let firstCoordinate = coordinates.first {
            let startAnnotation = CustomAnnotation(
                coordinate: firstCoordinate,
                title: "開始地点",
                subtitle: "ルートの開始",
                type: .start
            )
            annotations.append(startAnnotation)
        }
        
        // 終了地点のアノテーション
        if let lastCoordinate = coordinates.last, coordinates.count > 1 {
            let endAnnotation = CustomAnnotation(
                coordinate: lastCoordinate,
                title: "目的地",
                subtitle: "ルートの終了",
                type: .end
            )
            annotations.append(endAnnotation)
        }
    }
    
    // MARK: - Route Tracking Methods

    private func startRouteTracking() {
        // LocationManagerから位置情報の更新を監視
        LocationManager.shared.startLocationUpdates()
        
        // 定期的にルート逸脱チェックを実行
        Task {
            while isTrackingRoute {
                try await Task.sleep(nanoseconds: 5_000_000_000)//TODO: テストの値なので後で伸ばす
                checkRouteDeviation()
            }
        }
    }
    
    private func checkRouteDeviation() {
        guard isTrackingRoute,
              let currentLocation = LocationManager.shared.currentLocation,
              !routeCoordinates.isEmpty,
              !hasUserDismissedDeviationDialog else { return } // ユーザーがダイアログを閉じた後は自動表示しない
        
        let currentCoordinate = currentLocation
        let distanceToRoute = distanceFromCurrentLocationToRoute(currentCoordinate)
        
        print("📍 現在位置からルートまでの距離: \(Int(distanceToRoute))m")
        
        if distanceToRoute > routeDeviationThreshold && !showRouteDeviationDialog {
            print("⚠️ ルートから\(Int(distanceToRoute))m離れています（閾値: \(Int(routeDeviationThreshold))m）")
            DispatchQueue.main.async {
                self.showRouteDeviationDialog = true
            }
        }
    }
    
    private func distanceFromCurrentLocationToRoute(_ currentLocation: CLLocationCoordinate2D) -> Double {
        guard !routeCoordinates.isEmpty else { return 0.0 }
        
        var minDistance = Double.infinity
        
        // ルート上の各ポイントとの距離を計算
        for routePoint in routeCoordinates {
            let distance = calculateDistance(from: currentLocation, to: routePoint)
            if distance < minDistance {
                minDistance = distance
            }
        }
        
        // ルート上の線分との距離も計算（より正確な距離計算）
        for i in 0..<(routeCoordinates.count - 1) {
            let segmentStart = routeCoordinates[i]
            let segmentEnd = routeCoordinates[i + 1]
            let distanceToSegment = distanceFromPointToLineSegment(
                point: currentLocation,
                lineStart: segmentStart,
                lineEnd: segmentEnd
            )
            if distanceToSegment < minDistance {
                minDistance = distanceToSegment
            }
        }
        
        return minDistance
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    private func distanceFromPointToLineSegment(
        point: CLLocationCoordinate2D,
        lineStart: CLLocationCoordinate2D,
        lineEnd: CLLocationCoordinate2D
    ) -> Double {
        let A = point
        let B = lineStart
        let C = lineEnd
        
        // ベクトルBC
        let BC_x = C.longitude - B.longitude
        let BC_y = C.latitude - B.latitude
        
        // ベクトルBA
        let BA_x = A.longitude - B.longitude
        let BA_y = A.latitude - B.latitude
        
        // 内積を計算
        let dot = BC_x * BA_x + BC_y * BA_y
        let lenSq = BC_x * BC_x + BC_y * BC_y
        
        var param = -1.0
        if lenSq != 0 {
            param = dot / lenSq
        }
        
        var closestPoint: CLLocationCoordinate2D
        
        if param < 0 {
            closestPoint = lineStart
        } else if param > 1 {
            closestPoint = lineEnd
        } else {
            closestPoint = CLLocationCoordinate2D(
                latitude: lineStart.latitude + param * (lineEnd.latitude - lineStart.latitude),
                longitude: lineStart.longitude + param * (lineEnd.longitude - lineStart.longitude)
            )
        }
        
        return calculateDistance(from: point, to: closestPoint)
    }
}
