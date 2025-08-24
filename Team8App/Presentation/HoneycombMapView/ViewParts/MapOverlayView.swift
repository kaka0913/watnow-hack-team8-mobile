import SwiftUI
import MapKit

/// 地図上にポリラインを描画するオーバーレイビュー
struct MapOverlayView: UIViewRepresentable {
    let routes: [StoryRoute]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false // タッチイベントを無効化
        mapView.backgroundColor = .clear
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 既存のオーバーレイを削除
        mapView.removeOverlays(mapView.overlays)
        
        // 各ルートのポリラインをオーバーレイとして追加
        for route in routes {
            if let polylineString = getPolylineForRoute(route) {
                let coordinates = PolylineDecoder.decode(polylineString)
                
                if PolylineDecoder.isValidCoordinates(coordinates) && coordinates.count > 1 {
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    polyline.title = route.id // ルートIDを設定
                    mapView.addOverlay(polyline)
                    
                    print("🗺️ ポリライン追加: \(route.title) (\(coordinates.count)点)")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    /// ルートからポリライン文字列を取得
    /// - Parameter route: ストーリールート
    /// - Returns: ポリライン文字列、見つからない場合はnil
    private func getPolylineForRoute(_ route: StoryRoute) -> String? {
        return route.routePolyline
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = getColorForRoute(polyline.title)
                renderer.lineWidth = 4.0
                renderer.alpha = 0.8
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        /// ルートIDに基づいて色を決定
        /// - Parameter routeId: ルートID
        /// - Returns: ポリラインの色
        private func getColorForRoute(_ routeId: String?) -> UIColor {
            // ルートIDのハッシュ値を使って色を決定
            let hash = abs(routeId?.hashValue ?? 0)
            let colors: [UIColor] = [
                .systemBlue,
                .systemGreen,
                .systemOrange,
                .systemPurple,
                .systemPink,
                .systemTeal,
                .systemIndigo
            ]
            return colors[hash % colors.count]
        }
    }
}
