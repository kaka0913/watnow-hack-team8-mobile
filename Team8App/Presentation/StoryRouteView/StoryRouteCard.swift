import SwiftUI

struct StoryRouteCard: View {
    let route: StoryRoute
    let onStartRoute: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Route Header
            HStack(alignment: .top, spacing: 12) {
                // Route Icon
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(route.iconColor.emoji)
                            .font(.title2)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(route.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(route.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Route Details
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(route.duration)分")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1fkm", route.distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(route.category.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.3))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Route Highlights
            if !route.highlights.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("このルートのハイライト:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    ForEach(route.highlights) { highlight in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 20, height: 20)
                            
                            Text(highlight.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            
            // Start Route Button
            Button(action: onStartRoute) {
                HStack {
                    Text("✨ このルートを歩く")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(buttonBackgroundColor)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var iconBackgroundColor: Color {
        switch route.iconColor {
        case .pink:
            return Color.pink.opacity(0.8)
        case .green:
            return Color.green.opacity(0.8)
        case .purple:
            return Color.purple.opacity(0.8)
        case .blue:
            return Color.blue.opacity(0.8)
        case .orange:
            return Color.orange.opacity(0.8)
        }
    }
    
    private var buttonBackgroundColor: Color {
        switch route.iconColor {
        case .pink:
            return Color.pink
        case .green:
            return Color.green
        case .purple:
            return Color.purple
        case .blue:
            return Color.blue
        case .orange:
            return Color.orange
        }
    }
}