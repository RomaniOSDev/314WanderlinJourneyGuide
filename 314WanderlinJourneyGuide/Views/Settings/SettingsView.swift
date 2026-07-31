import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    feedbackCard
                    settingsGroup
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 80)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .withScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    FeedbackHelper.delete()
                    AppDataStore.resetAllData()
                }
            } message: {
                Text("This will permanently delete all destinations, checklists, and achievements.")
            }
        }
    }

    private var feedbackCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color("AppPrimary"))
                    Text("Feedback")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .padding(.bottom, 8)

                Toggle(isOn: $store.soundEnabled) {
                    Label("Sound Effects", systemImage: store.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .tint(Color("AppPrimary"))
                .foregroundStyle(Color("AppTextPrimary"))
                .onChange(of: store.soundEnabled) { _ in
                    if store.hapticEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }

                Divider().overlay(Color.white.opacity(0.08)).padding(.vertical, 4)

                Toggle(isOn: $store.hapticEnabled) {
                    Label("Haptic Feedback", systemImage: store.hapticEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                }
                .tint(Color("AppPrimary"))
                .foregroundStyle(Color("AppTextPrimary"))
                .onChange(of: store.hapticEnabled) { enabled in
                    if enabled {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }

                Text("Sound off mutes every system click in the app. Haptics only affect vibration.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.top, 8)
            }
        }
    }

    private var settingsGroup: some View {
        VStack(spacing: 0) {
            settingsButton(icon: "star.fill", title: "Rate Us") {
                FeedbackHelper.tap()
                rateApp()
            }

            Divider().overlay(Color.white.opacity(0.08))

            Link(destination: AppLink.privacy) {
                settingsLinkRow(icon: "hand.raised.fill", title: "Privacy Policy")
            }

            Divider().overlay(Color.white.opacity(0.08))

            Link(destination: AppLink.support) {
                settingsLinkRow(icon: "questionmark.circle.fill", title: "Support")
            }

            Divider().overlay(Color.white.opacity(0.08))

            Button {
                FeedbackHelper.tap()
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .frame(width: 28)
                        .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.35))
                    Text("Reset All Data")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.35))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(16)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface").opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func settingsButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsLinkRow(icon: icon, title: title)
        }
        .buttonStyle(.plain)
    }

    private func settingsLinkRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
