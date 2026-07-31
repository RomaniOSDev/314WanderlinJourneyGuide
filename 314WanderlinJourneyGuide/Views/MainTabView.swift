import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppDataStore

    var body: some View {
        ScreenBackground {
            ZStack(alignment: .bottom) {
                Group {
                    switch store.selectedTab {
                    case .bucket:
                        TravelBucketView()
                    case .packing:
                        PackingOrganizerView()
                    case .stats:
                        StatsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .dismissKeyboardOnTap()

                CustomTabBar(selectedTab: $store.selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                if let achievement = store.newlyUnlockedAchievement {
                    AchievementBanner(achievement: achievement) {
                        store.dismissAchievementBanner()
                    }
                    .padding(.top, 8)
                    .zIndex(100)
                }
            }
        }
    }
}
