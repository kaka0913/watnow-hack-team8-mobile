//
//  WalkSummaryViewModel.swift
//  Team8App
//
//  Created by 김준용 on 2025/08/04.
//

// WalkSummaryViewModel.swift
import Foundation

@Observable
class WalkSummaryViewModel {
    var backButtonTitle: String = "戻る"
    var title: String = "   📖 あなたの散歩の軌跡"
    var subtitle: String = "   黄の蜜蜂が防ぐ、古き良き商店街物語"
    var time: String = "48分"
    var distance: String = "2.3 km"
    var visitedCount: String = "３箇所訪問"
    var visitedSpots: [String] = [
        "伝統なお菓子店「伝統堂」",
        "レトロなカフェ「レトカ」",
        "手作り雑貨店「手雑店」"
    ]
    var shouldPost: Bool? = nil
    
    // Dismiss action
    var onDismiss: (() -> Void)?
    
    // Navigate to Home action
    var onNavigateToHome: (() -> Void)?
    
    func dismiss() {
        onDismiss?()
    }
    
    func navigateToHome() {
        onNavigateToHome?()
    }
}
