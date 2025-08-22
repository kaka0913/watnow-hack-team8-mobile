import SwiftUI

struct StoryRouteView: View {
    @State private var viewModel = StoryRouteViewModel()
    
    var body: some View {
    
            ScrollView {
                LazyVStack(spacing: 16) {
                    headerView
                    
                    if viewModel.isLoading {
                        ProgressView("読み込み中...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        errorView(errorMessage)
                    } else {
                        ForEach(viewModel.storyRoutes) { route in
                            StoryRouteCard(
                                route: route,
                                onStartRoute: { viewModel.startRoute(route) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("戻る") {
                        // ナビゲーション戻る処理
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("🗺")
                                    .font(.caption)
                            )
                        Text("物語のあるルート")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("どのルートを歩きますか？")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

        }
        .padding()
    }


#Preview {
    StoryRouteView()
}
