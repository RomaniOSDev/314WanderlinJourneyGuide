import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [(title: String, subtitle: String, icon: String)] = [
        ("Plan Your Trip", "Organize destinations and preparations in one calm travel hub.", "map.fill"),
        ("Add Destinations", "Save places you want to visit and mark them when you go.", "suitcase.fill"),
        ("Track Progress", "Charts, streaks, and achievements keep your wanderlust alive.", "chart.xyaxis.line")
    ]

    var body: some View {
        ScreenBackground {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(title: page.title, subtitle: page.subtitle, icon: page.icon)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.55, dampingFraction: 0.78), value: currentPage)

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentPage)
                    }
                }
                .padding(.bottom, 28)

                Button {
                    FeedbackHelper.tap()
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                            currentPage += 1
                        }
                    } else {
                        FeedbackHelper.save()
                        store.completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(Color("AppBackground"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 44)
            }
        }
    }

    @ViewBuilder
    private func onboardingPage(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.14))
                    .frame(width: 190, height: 190)

                Circle()
                    .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
                    .frame(width: 210, height: 210)

                Image(systemName: icon)
                    .font(.system(size: 68, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .frame(height: 220)

            VStack(spacing: 12) {
                Text("Wanderlin")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(Color("AppPrimary"))

                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }

            Spacer()
            Spacer()
        }
    }
}
