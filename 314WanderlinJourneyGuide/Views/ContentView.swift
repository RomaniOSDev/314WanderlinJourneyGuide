import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .onAppear {
            configureChrome()
        }
    }

    private func configureChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(named: "AppPrimary")

        UIScrollView.appearance().backgroundColor = .clear
        UITextField.appearance().keyboardAppearance = .dark
    }
}
