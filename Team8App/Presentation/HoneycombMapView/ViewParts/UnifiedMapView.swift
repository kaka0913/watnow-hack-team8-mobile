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
        print("🗺️ UnifiedMapView.updateUIView() 開始")
        print("🔍 処理対象ルート数: \(routes.count)")
        
        // 現在表示されているポリラインをログ出力
        print("📍 現在の地図上のポリライン数: \(mapView.overlays.count)")
        for (index, overlay) in mapView.overlays.enumerated() {
            if let polyline = overlay as? MKPolyline {
                print("   - ポリライン\(index): \(polyline.pointCount)点")
            }
        }
        
        // 既存のポリラインを削除
        mapView.removeOverlays(mapView.overlays)
        print("🗑️ 既存のポリラインを削除")
        
        // ルートごとにポリラインを追加
        for (index, route) in routes.enumerated() {
            print("🔍 ルート処理中[\(index)]: \(route.title)")
            print("   - ID: \(route.id)")
            
            if let polylineString = route.routePolyline, !polylineString.isEmpty {
                print("   - ポリライン文字列長: \(polylineString.count)")
                print("   - ポリライン先頭20文字: \(String(polylineString.prefix(20)))")
                
                let coordinates = PolylineDecoder.decode(polylineString)
                print("   - デコード結果: \(coordinates.count)個の座標")
                
                if coordinates.count >= 2 {
                    if coordinates.count > 0 {
                        print("   - 開始座標: (\(coordinates[0].latitude), \(coordinates[0].longitude))")
                        print("   - 終了座標: (\(coordinates[coordinates.count-1].latitude), \(coordinates[coordinates.count-1].longitude))")
                    }
                    
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    polyline.title = route.title // タイトルを設定してデバッグ用
                    mapView.addOverlay(polyline)
                    print("✅ ポリライン追加完了: \(route.title)")
                } else {
                    print("❌ 座標数が不足: \(coordinates.count)個")
                }
            } else {
                print("❌ ポリライン情報がありません")
            }
        }
        
        print("🗺️ UnifiedMapView.updateUIView() 完了")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(routes: routes, onRouteSelect: onRouteSelect)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var routes: [StoryRoute]
        var onRouteSelect: (StoryRoute) -> Void
        var hasSetInitialRegion = false  // 初回の地図範囲設定フラグ
        var userHasInteracted = false    // ユーザーが地図を操作したかのフラグ
        
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
        
        // ユーザーが地図を手動で操作したことを検出
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            userHasInteracted = true
            print("🤚 ユーザーによる地図操作を検出")
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
