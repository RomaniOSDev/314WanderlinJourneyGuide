import SwiftUI

struct FloatingActionButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            FeedbackHelper.tap()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("AppBackground"))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 12, y: 6)
                )
        }
        .buttonStyle(.plain)
    }
}
