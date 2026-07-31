import SwiftUI

/// Shared atmospheric background for every screen.
struct AtmosphereBackground: View {
    var body: some View {
        Color("AppBackground")
            .overlay {
                Image("HeroBackground")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.5)
            }
            .overlay {
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.25),
                        Color("AppBackground").opacity(0.1),
                        Color("AppBackground").opacity(0.55)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipped()
    }
}

/// Wrapper for screens that are NOT inside a NavigationStack.
struct ScreenBackground<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                AtmosphereBackground()
                    .ignoresSafeArea()
            }
    }
}

extension View {
    /// Paints the atmosphere behind a screen's content. Use inside a NavigationStack.
    func withScreenBackground() -> some View {
        background {
            AtmosphereBackground()
                .ignoresSafeArea()
        }
    }
}
