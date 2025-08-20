import SwiftUI

struct WalkOptionsSection: View {
    let viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 目的地を決めて出発
            WalkOptionCard(
                icon: "🧭",
                iconColor: .white,
                backgroundColor: .blue,
                title: viewModel.destinationWalkTitle,
                subtitle: viewModel.destinationWalkSubtitle,
                buttonText: "散歩を始める",
                buttonColor: .blue,
                action: viewModel.startDestinationWalk
            )
            
            // 目的地なしで出発
            WalkOptionCard(
                icon: "⏰",
                iconColor: .white,
                backgroundColor: .green,
                title: viewModel.noDestinationWalkTitle,
                subtitle: viewModel.noDestinationWalkSubtitle,
                buttonText: "散歩を始める",
                buttonColor: .green,
                action: viewModel.startFreeWalk
            )
            
            // ハニカムマップを見る
            WalkOptionCard(
                icon: "💜",
                iconColor: .white,
                backgroundColor: Color(red: 0.7, green: 0.4, blue: 0.9),
                title: viewModel.exploreMapTitle,
                subtitle: viewModel.exploreMapSubtitle,
                buttonText: "地図を探索する",
                buttonColor: Color(red: 0.7, green: 0.4, blue: 0.9),
                action: viewModel.exploreHoneycombMap
            )
        }
    }
}

#Preview {
    WalkOptionsSection(viewModel: HomeViewModel())
        .padding(.horizontal, 24)
}
