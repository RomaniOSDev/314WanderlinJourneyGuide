import Foundation

struct AchievementDefinition: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let emoji: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_step", title: "First Step", description: "Add your first destination", iconName: "mappin.and.ellipse", emoji: "📍"),
        AchievementDefinition(id: "jet_setter", title: "Jet Setter", description: "Add 10 destinations", iconName: "airplane", emoji: "✈️"),
        AchievementDefinition(id: "well_packed", title: "Well Packed", description: "Complete your first checklist item", iconName: "checkmark.circle.fill", emoji: "🎒"),
        AchievementDefinition(id: "power_user", title: "Power User", description: "Create 50 checklist items", iconName: "bolt.fill", emoji: "⚡"),
        AchievementDefinition(id: "active_user", title: "Active User", description: "Visit 10 destinations", iconName: "globe.americas.fill", emoji: "🌍"),
        AchievementDefinition(id: "dedicated_user", title: "Dedicated User", description: "Visit 50 destinations", iconName: "star.fill", emoji: "🏆"),
        AchievementDefinition(id: "three_day_streak", title: "Three-Day Streak", description: "Use the app 3 days in a row", iconName: "flame.fill", emoji: "🔥"),
        AchievementDefinition(id: "week_long_habit", title: "Week-Long Habit", description: "Use the app 7 days in a row", iconName: "calendar", emoji: "📅")
    ]

    func isUnlocked(
        destinations: Int,
        visitedDestinations: Int,
        checklistItems: Int,
        checklistsCompleted: Int,
        streakDays: Int
    ) -> Bool {
        switch id {
        case "first_step": return destinations >= 1
        case "jet_setter": return destinations >= 10
        case "well_packed": return checklistsCompleted >= 1
        case "power_user": return checklistItems >= 50
        case "active_user": return visitedDestinations >= 10
        case "dedicated_user": return visitedDestinations >= 50
        case "three_day_streak": return streakDays >= 3
        case "week_long_habit": return streakDays >= 7
        default: return false
        }
    }
}
