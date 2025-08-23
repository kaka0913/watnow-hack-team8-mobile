import SwiftUI

struct DestinationSettingView: View {
    @State private var viewModel = DestinationSettingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            ZStack {
                Color(red: 1.0, green: 1.0, blue: 0.90)
                    .ignoresSafeArea()
                
                    VStack(spacing: 20) {
                        // Header
                        DestinationHeaderView(onBack: {
                            viewModel.dismiss()
                        })
                        
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
    }
}
