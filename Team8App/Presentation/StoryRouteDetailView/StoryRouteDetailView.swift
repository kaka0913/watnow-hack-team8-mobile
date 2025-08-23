import SwiftUI

struct StoryRouteDetailView: View {
    @Bindable var viewModel: StoryRouteDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // ヘッダー部分
                    headerView
                    
                    // コンテンツ部分
                    contentView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // 閉じるボタン
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.trailing, 20)
                .padding(.top, 10)
            }
            
            // タイトル
            Text(viewModel.route.title)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // 位置情報とカテゴリ
            HStack(spacing: 8) {
                Image(systemName: "location")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("\(viewModel.formatLocation()) • \(viewModel.formatDate())")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // 説明文
            Text(viewModel.route.description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // 時間・距離・カテゴリ情報
            routeInfoView
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Route Info View
    private var routeInfoView: some View {
        HStack(spacing: 20) {
            // 時間
            infoItem(
                icon: "clock",
                value: viewModel.formatDuration(),
                label: ""
            )
            
            // 距離
            infoItem(
                icon: "location",
                value: viewModel.formatDistance(),
                label: ""
            )
            
            // カテゴリ
            categoryView
        }
        .padding(.horizontal, 20)
    }
    
    private func infoItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
    
    private var categoryView: some View {
        Text(viewModel.route.category.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 16) {
            // タグ表示
            if !viewModel.route.highlights.isEmpty {
                tagsView
            }
            
            // 道のりセクション
            routeStepsView
            
            // 開始ボタン
            startButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }
    
    // MARK: - Tags View
    private var tagsView: some View {
        HStack {
            ForEach(viewModel.route.highlights.prefix(3)) { highlight in
                Text("#\(highlight.name)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }
    
    // MARK: - Route Steps View
    private var routeStepsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // セクションヘッダー
            HStack {
                Image(systemName: "map")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                Text("道のり")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.bottom, 16)
            
            // ルートステップ
            VStack(spacing: 12) {
                ForEach(Array(viewModel.route.highlights.enumerated()), id: \.element.id) { index, highlight in
                    routeStepCard(
                        step: index + 1,
                        title: highlight.name,
                        description: getStepDescription(for: highlight),
                        distance: getStepDistance(for: index),
                        isCompleted: false
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func routeStepCard(step: Int, title: String, description: String, distance: String, isCompleted: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // ステップ番号
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.orange)
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // ステップ内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(distance)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            viewModel.startNavigation()
        }) {
            HStack {
                if viewModel.isStartingNavigation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("閉じる")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .disabled(viewModel.isStartingNavigation)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Methods
    private func getStepDescription(for highlight: RouteHighlight) -> String {
        // ハイライトに基づいて説明を生成
        switch highlight.name {
        case let name where name.contains("公園"):
            return "雨上がりの緑が美しい都心のオアシス"
        case let name where name.contains("カフェ"):
            return "おしゃれなカフェで温かいコーヒーを"
        case let name where name.contains("展望"):
            return "虹が見えた特別な展望スポット"
        default:
            return "素敵な発見が待っています"
        }
    }
    
    private func getStepDistance(for index: Int) -> String {
        let distances = ["200m", "150m", "300m"]
        return distances.indices.contains(index) ? distances[index] : "100m"
    }
}

#Preview {
    StoryRouteDetailView(
        viewModel: StoryRouteDetailViewModel(
            route: StoryRoute(
                id: "1",
                title: "雨上がりの虹色散歩道",
                description: "雨上がりの街に現れた小さな虹を追いかけて、思いがけない出会いと発見に満ちた散歩になりました。",
                duration: 38,
                distance: 2.1,
                category: .nature,
                iconColor: .green,
                highlights: [
                    RouteHighlight(name: "青山公園", iconColor: "green"),
                    RouteHighlight(name: "表参道カフェ", iconColor: "orange"),
                    RouteHighlight(name: "虹の橋展望台", iconColor: "blue")
                ]
            )
        )
    )
}
