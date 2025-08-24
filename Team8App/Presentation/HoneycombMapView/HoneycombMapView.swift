import SwiftUI

struct HoneycombMapView: View {
    @State private var viewModel = HoneycombMapViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            MapHeaderView(
                isMapView: viewModel.isMapView,
                onDisplayModeToggle: viewModel.toggleDisplayMode,
                onBackTap: {
                    dismiss()
                }
            )
            
            // メインコンテンツ
            if viewModel.isMapView {
                HoneycombMapContentView(
                    routes: viewModel.storyRoutes,
                    onRouteSelect: viewModel.selectRoute
                )
            } else {
                HoneycombListContentView(
                    routes: viewModel.storyRoutes,
                    onRouteSelect: viewModel.selectRoute
                )
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowingRouteDetail) {
            if let selectedRoute = viewModel.selectedRoute {
                StoryRouteDetailView(
                    viewModel: StoryRouteDetailViewModel(route: selectedRoute)
                )
                .onDisappear {
                    viewModel.clearSelection()
                }
            }
        }
        .onAppear {
            print("📱 ハニカムマップ画面が表示されました")
            // データを更新
            viewModel.refreshWalks()
        }
    }
}

#Preview {
    HoneycombMapView()
}
