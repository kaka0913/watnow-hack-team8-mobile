import SwiftUI

struct DestinationSettingView: View {
    @State private var viewModel = DestinationSettingViewModel()
    @Environment(\.dismiss) private var dismiss
    
   var body: some View {
            ZStack {
                Color(red: 1.0, green: 1.0, blue: 0.90)
                    .ignoresSafeArea()
                
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20) // ナビゲーションバーとの間隔
                        
                        // Location Settings Card
                        LocationSettingCard(
                            startLocation: $viewModel.startLocation,
                            destination: $viewModel.destination,
                            destinationPlaceholder: viewModel.destinationPlaceholder
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
                                    StoryRouteView()
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
    }
}
