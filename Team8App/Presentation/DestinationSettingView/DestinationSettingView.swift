import SwiftUI

struct DestinationSettingView: View {
    @State private var viewModel = DestinationSettingViewModel()
    @State private var showStoryRouteView = false
    @Environment(\.dismiss) private var dismiss
    
   var body: some View {
            ZStack {
                Color(red: 1.0, green: 1.0, blue: 0.90)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // キーボードを閉じる
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)
                        
                        // Location Settings Card
                        LocationSettingCard(
                            startLocation: $viewModel.startLocation,
                            destination: $viewModel.destination,
                            destinationPlaceholder: viewModel.destinationPlaceholder,
                            onPlaceSelected: viewModel.updateSelectedPlace,
                            onStartPlaceSelected: viewModel.updateSelectedStartPlace
                        )
                        
                        // Theme Selection Card
                        ThemeSelectionCard(
                            selectedTheme: $viewModel.selectedTheme,
                            showThemeSelection: $viewModel.showThemeSelection,
                            themePlaceholder: viewModel.themePlaceholder,
                            availableThemes: viewModel.availableThemes,
                            onThemeSelect: viewModel.selectTheme
                        )

                        // Search Button -
                        RouteSearchButton(
                            isFormValid: viewModel.isFormValid,
                            isLoading: viewModel.isLoading,
                            onSearchRoute: {
                                Task {
                                    await viewModel.searchRoute()
                                    // メインスレッドで状態更新を確実に実行
                                    await MainActor.run {
                                        print("🔍 検索結果: \(viewModel.routeProposals.count)件")
                                        if viewModel.hasRouteProposals {
                                            print("✅ 遷移開始")
                                            showStoryRouteView = true
                                        } else {
                                            print("❌ API失敗のため、モックデータで遷移")
                                            // API失敗時でもStoryRouteViewに遷移（モックデータを表示）
                                            showStoryRouteView = true
                                        }
                                    }
                                }
                            }
                        )
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                }
                .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .navigationTitle("目的地設定")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false) // 明示的にナビゲーションバーを表示
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .navigationDestination(isPresented: $showStoryRouteView) {
                    StoryRouteView()
                        .onAppear {
                            print("📱 StoryRouteView表示開始")
                            // ViewModelにAPIデータを渡す
                            if !viewModel.routeProposals.isEmpty {
                                print("🔄 APIデータをStoryRouteViewModelに設定: \(viewModel.routeProposals.count)件")
                                StoryRouteViewModel.shared.setRouteProposals(viewModel.routeProposals)
                            } else {
                                print("🎭 モックデータを使用")
                            }
                        }
                }
    }
}
