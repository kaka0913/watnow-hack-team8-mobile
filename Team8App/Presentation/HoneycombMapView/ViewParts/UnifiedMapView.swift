import SwiftUI
import MapKit

/// アノテーションとポリラインを統合して表示するマップビュー
struct UnifiedMapView: UIViewRepresentable {
    let routes: [StoryRoute]
    let onRouteSelect: (StoryRoute) -> Void
    
    // 京都を中心とした地図の初期設定
    private let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.region = initialRegion
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // コーディネーターに最新のデータを渡す
        context.coordinator.routes = routes
        context.coordinator.onRouteSelect = onRouteSelect
        
        print("🔍 処理対象ルート数: \(routes.count)")
        
        // ルートが空の場合は何もしない（初期化時の空配列での呼び出しを防ぐ）
        guard !routes.isEmpty else {
            print("⚠️ ルートが空のため、マップ更新をスキップします")
            return
        }
        
        // 既存のアノテーションとオーバーレイを削除
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.removeOverlays(mapView.overlays)
        
        // 各ルートにアノテーションとポリラインを追加
        var addedPolylines: [String] = []  // 重複確認用
        var allCoordinates: [CLLocationCoordinate2D] = []  // 全座標を収集してマップ範囲を調整
        
        for route in routes {
            print("🔍 ルート処理中: \(route.title)")
            print("🔍 ポリラインデータ: \(route.routePolyline != nil ? "あり" : "なし")")
            
            // ポリラインを追加
            if let polylineString = route.routePolyline {
                let coordinates = PolylineDecoder.decode(polylineString)
                
                if PolylineDecoder.isValidCoordinates(coordinates) && coordinates.count > 1 {
                    // 重複チェック
                    let polylineKey = polylineString.prefix(20).description  // 最初の20文字で重複判定
                    if addedPolylines.contains(polylineKey) {
                        print("⚠️ 重複ポリライン検出: \(route.title)")
                    } else {
                        addedPolylines.append(polylineKey)
                        print("✅ 新規ポリライン: \(route.title)")
                    }
                    
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    polyline.title = route.id
                    mapView.addOverlay(polyline)
                    
                    // 全座標を収集
                    allCoordinates.append(contentsOf: coordinates)
                    
                    // アノテーションを追加（ポリラインの開始点に配置）
                    let annotation = RouteAnnotation(route: route, coordinate: coordinates[0])
                    mapView.addAnnotation(annotation)
                    
                    print("🗺️ ポリライン追加: \(route.title) (\(coordinates.count)点)")
                } else {
                    print("⚠️ ポリラインデータが無効: \(route.title)")
                    // ポリラインデータがない場合は京都駅周辺にアノテーションを配置
                    let annotation = RouteAnnotation(route: route, coordinate: initialRegion.center)
                    mapView.addAnnotation(annotation)
                }
            } else {
                print("⚠️ ポリラインデータがない: \(route.title)")
                // ポリラインデータがない場合は京都駅周辺にアノテーションを配置
                let annotation = RouteAnnotation(route: route, coordinate: initialRegion.center)
                mapView.addAnnotation(annotation)
            }
        }
        
        // マップの表示範囲を全ルートに合わせて調整
        if !allCoordinates.isEmpty {
            let minLat = allCoordinates.map { $0.latitude }.min() ?? initialRegion.center.latitude
            let maxLat = allCoordinates.map { $0.latitude }.max() ?? initialRegion.center.latitude
            let minLon = allCoordinates.map { $0.longitude }.min() ?? initialRegion.center.longitude
            let maxLon = allCoordinates.map { $0.longitude }.max() ?? initialRegion.center.longitude
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.2,  // 20%のマージンを追加
                longitudeDelta: (maxLon - minLon) * 1.2
            )
            
            let adjustedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(adjustedRegion, animated: true)
            
            print("🗺️ マップ範囲調整: 中心(\(center.latitude), \(center.longitude)), スパン(\(span.latitudeDelta), \(span.longitudeDelta))")
            print("📊 重複ポリライン統計: 重複 \(routes.count - addedPolylines.count) 件, ユニーク \(addedPolylines.count) 件")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(routes: routes, onRouteSelect: onRouteSelect)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var routes: [StoryRoute]
        var onRouteSelect: (StoryRoute) -> Void
        
        init(routes: [StoryRoute], onRouteSelect: @escaping (StoryRoute) -> Void) {
            self.routes = routes
            self.onRouteSelect = onRouteSelect
        }
        
        // MARK: - MKMapViewDelegate
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let routeAnnotation = annotation as? RouteAnnotation else {
                return nil
            }
            
            let identifier = "RouteAnnotation"
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.markerTintColor = routeColor(for: routeAnnotation.route)
            annotationView.glyphImage = UIImage(systemName: "location.fill")
            annotationView.glyphTintColor = .white
            
            // タップアクションを設定
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
            annotationView.addGestureRecognizer(tapGesture)
            annotationView.tag = routes.firstIndex(where: { $0.id == routeAnnotation.route.id }) ?? 0
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                // ルートIDから色を決定
                if let routeId = polyline.title,
                   let route = routes.first(where: { $0.id == routeId }) {
                    renderer.strokeColor = routeColor(for: route)
                    print("🎨 ポリライン色設定: \(route.title) -> \(routeColor(for: route))")
                } else {
                    renderer.strokeColor = UIColor.systemBlue
                    print("🎨 デフォルト色設定: systemBlue")
                }
                
                renderer.lineWidth = 8.0  // 線をさらに太くして見やすくする
                renderer.alpha = 0.8     // 少し透明にして重なりを見やすくする
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        @objc private func annotationTapped(_ gesture: UITapGestureRecognizer) {
            guard let annotationView = gesture.view as? MKAnnotationView,
                  let routeAnnotation = annotationView.annotation as? RouteAnnotation else {
                return
            }
            
            onRouteSelect(routeAnnotation.route)
        }
        
        /// ルートの色を取得
        private func routeColor(for route: StoryRoute) -> UIColor {
            // ルートIDに基づいて固有の色を生成
            let colors: [UIColor] = [
                UIColor.systemRed,      // 赤
                UIColor.systemBlue,     // 青
                UIColor.systemGreen,    // 緑
                UIColor.systemOrange,   // オレンジ
                UIColor.systemPurple,   // 紫
                UIColor.systemPink,     // ピンク
                UIColor.systemTeal,     // ティール
                UIColor.systemIndigo,   // インディゴ
                UIColor.systemBrown,    // 茶色
                UIColor.systemCyan      // シアン
            ]
            
            // ルートIDのハッシュ値を使って色を決定
            let index = abs(route.id.hashValue) % colors.count
            return colors[index]
        }
    }
}

/// ルート用のカスタムアノテーション
class RouteAnnotation: NSObject, MKAnnotation {
    let route: StoryRoute
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return route.title
    }
    
    var subtitle: String? {
        return route.description
    }
    
    init(route: StoryRoute, coordinate: CLLocationCoordinate2D) {
        self.route = route
        self.coordinate = coordinate
        super.init()
    }
}

/// ルートの色を取得するヘルパー関数
private func routeColor(for route: StoryRoute) -> UIColor {
    // ルートIDに基づいて固有の色を生成
    let colors: [UIColor] = [
        UIColor.systemRed,      // 赤
        UIColor.systemBlue,     // 青
        UIColor.systemGreen,    // 緑
        UIColor.systemOrange,   // オレンジ
        UIColor.systemPurple,   // 紫
        UIColor.systemPink,     // ピンク
        UIColor.systemTeal,     // ティール
        UIColor.systemIndigo,   // インディゴ
        UIColor.systemBrown,    // 茶色
        UIColor.systemCyan      // シアン
    ]
    
    // ルートIDのハッシュ値を使って色を決定
    let index = abs(route.id.hashValue) % colors.count
    return colors[index]
}
