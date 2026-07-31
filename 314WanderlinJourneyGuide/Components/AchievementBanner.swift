import SwiftUI

struct AchievementBanner: View {
    let achievement: AchievementDefinition
    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Text(achievement.emoji)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Unlocked!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))

                    Text(achievement.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    Text(achievement.description)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }

                Spacer()

                Button {
                    FeedbackHelper.tap()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppSurface"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color("AppPrimary").opacity(0.3), radius: 12, y: 6)
            )
            .padding(.horizontal, 16)
            .offset(y: appeared ? 0 : -120)
            .opacity(appeared ? 1 : 0)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    appeared = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
}
