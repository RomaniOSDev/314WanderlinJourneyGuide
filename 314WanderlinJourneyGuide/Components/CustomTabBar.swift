import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    private let bottomFill = Color(red: 0.05, green: 0.20, blue: 0.28)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        FeedbackHelper.tap()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 16, weight: .semibold))
                            Text(tab.title)
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(selectedTab == tab ? Color("AppPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedTab == tab ? Color("AppPrimary").opacity(0.16) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 14)
            .padding(.top, 4)
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .background {
            bottomFill
                .ignoresSafeArea(edges: .bottom)
        }
    }
}
