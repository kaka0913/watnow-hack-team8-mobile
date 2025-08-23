import SwiftUI

struct StoryRouteView: View {
    @State private var viewModel = StoryRouteViewModel.shared
    @State private var showNavigationView = false
    @State private var selectedRoute: StoryRoute?
    
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
                        let displayProposals = viewModel.routeProposals.isEmpty ? viewModel.getMockRouteProposals() : viewModel.routeProposals
                        ForEach(displayProposals, id: \.proposalId) { proposal in
                            StoryRouteCard(
                                route: convertToStoryRoute(proposal),
                                onStartRoute: { 
                                    let route = convertToStoryRoute(proposal)
                                    selectedRoute = route
                                    showNavigationView = true
                                    viewModel.startRoute(route)
                                }
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
            .navigationDestination(isPresented: $showNavigationView) {
                if let route = selectedRoute {
                    NavigationView(selectedRoute: route)
                } else {
                    EmptyView()
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
    
    private func convertToStoryRoute(_ proposal: RouteProposal) -> StoryRoute {
        return StoryRoute(
            id: proposal.proposalId ?? UUID().uuidString,
            title: proposal.title,
            description: proposal.generatedStory ?? "素晴らしい散歩ルートです",
            duration: proposal.estimatedDurationMinutes ?? 60,
            distance: Double(proposal.estimatedDistanceMeters ?? 2000) / 1000.0, // メートルをキロメートルに変換
            category: mapThemeToCategory(proposal.theme ?? "gourmet"),
            iconColor: .orange,
            highlights: (proposal.displayHighlights ?? []).map { 
                RouteHighlight(name: $0, iconColor: "orange") 
            }
        )
    }
    
    private func mapThemeToCategory(_ theme: String) -> StoryRoute.RouteCategory {
        switch theme {
        case "nature":
            return .nature
        case "culture", "art":
            return .art
        default:
            return .gourmet
        }
    }

