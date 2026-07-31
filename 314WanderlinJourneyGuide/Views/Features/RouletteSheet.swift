import SwiftUI

struct RouletteSheet: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = "…"
    @State private var selected: Destination?
    @State private var isSpinning = false
    @State private var spinTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.14))
                        .frame(width: 220, height: 220)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 236, height: 236)
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .animation(
                            isSpinning
                                ? .linear(duration: 0.8).repeatForever(autoreverses: false)
                                : .default,
                            value: isSpinning
                        )

                    VStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color("AppPrimary"))
                        Text(displayName)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .animation(.easeInOut(duration: 0.12), value: displayName)
                    }
                }

                if let selected {
                    Text(selected.country.isEmpty ? "Ready for adventure" : selected.country)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(selected.plannedDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                } else {
                    Text("Spin to pick a trip from your wishlist")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                Button {
                    spin()
                } label: {
                    Text(isSpinning ? "Spinning…" : "Spin")
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
                .disabled(isSpinning || store.rouletteCandidates.isEmpty)
                .padding(.horizontal, 24)

                if let selected {
                    Button {
                        FeedbackHelper.tap()
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            NotificationCenter.default.post(
                                name: .openDestination,
                                object: nil,
                                userInfo: ["id": selected.id.uuidString]
                            )
                        }
                    } label: {
                        Text("Open Destination")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.bottom, 24)
            .withScreenBackground()
            .navigationTitle("Trip Roulette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .onDisappear {
                spinTask?.cancel()
            }
        }
    }

    private func spin() {
        let candidates = store.rouletteCandidates
        guard !candidates.isEmpty else { return }

        FeedbackHelper.tap()
        isSpinning = true
        selected = nil
        spinTask?.cancel()

        spinTask = Task { @MainActor in
            let ticks = 18
            for i in 0..<ticks {
                if Task.isCancelled { return }
                displayName = candidates[i % candidates.count].name
                try? await Task.sleep(nanoseconds: UInt64(40_000_000 + i * 12_000_000))
            }

            let pick = candidates.randomElement()
            selected = pick
            displayName = pick?.name ?? "—"
            isSpinning = false
            FeedbackHelper.success()
        }
    }
}

extension Notification.Name {
    static let openDestination = Notification.Name("openDestination")
}
