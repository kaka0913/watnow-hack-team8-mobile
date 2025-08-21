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
                title: WalkOptionConstants.destinationWalkTitle,
                subtitle: WalkOptionConstants.destinationWalkSubtitle,
                buttonText: WalkOptionConstants.walkButtonText,
                buttonColor: .blue,
                action: viewModel.startDestinationWalk
            )
            
            // 目的地なしで出発
            WalkOptionCard(
                icon: "⏰",
                iconColor: .white,
                backgroundColor: .green,
                title: WalkOptionConstants.noDestinationWalkTitle,
                subtitle: WalkOptionConstants.noDestinationWalkSubtitle,
                buttonText: WalkOptionConstants.walkButtonText,
                buttonColor: .green,
                action: viewModel.startFreeWalk
            )
            
            // ハニカムマップを見る
            WalkOptionCard(
                icon: "💜",
                iconColor: .white,
                backgroundColor: Color(red: 0.7, green: 0.4, blue: 0.9),
                title: WalkOptionConstants.exploreMapTitle,
                subtitle: WalkOptionConstants.exploreMapSubtitle,
                buttonText: WalkOptionConstants.exploreButtonText,
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
