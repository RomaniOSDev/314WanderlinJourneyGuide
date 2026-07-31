import Foundation
import Combine

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private static let storageKey = "AppDataStore.v1"

    @Published var hasSeenOnboarding: Bool = false
    @Published var destinations: [Destination] = []
    @Published var checklistItems: [ChecklistItem] = []
    @Published var favouritePhraseIDs: [String] = []
    @Published var streakDays: Int = 0
    @Published var lastActivityDate: Date?
    @Published var achievementsUnlocked: [String] = []
    @Published var newlyUnlockedAchievement: AchievementDefinition?
    @Published var selectedTab: AppTab = .bucket
    @Published var soundEnabled: Bool = true
    @Published var hapticEnabled: Bool = true

    private var cancellables = Set<AnyCancellable>()

    private struct PersistedData: Codable {
        var hasSeenOnboarding: Bool
        var destinations: [Destination]
        var checklistItems: [ChecklistItem]
        var favouritePhraseIDs: [String]
        var streakDays: Int
        var lastActivityDate: Date?
        var achievementsUnlocked: [String]
        var soundEnabled: Bool?
        var hapticEnabled: Bool?
    }

    init() {
        load()
        recordActivity()
        save()
        ReminderService.requestAuthorizationIfNeeded()
        syncAllReminders()

        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in
                self?.reloadAfterReset()
            }
            .store(in: &cancellables)

        $destinations.dropFirst().sink { [weak self] _ in
            self?.save()
            self?.checkAchievements()
            self?.syncAllReminders()
        }.store(in: &cancellables)
        $checklistItems.dropFirst().sink { [weak self] _ in self?.save(); self?.checkAchievements() }.store(in: &cancellables)
        $favouritePhraseIDs.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $hasSeenOnboarding.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $achievementsUnlocked.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $streakDays.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $soundEnabled.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $hapticEnabled.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
    }

    // MARK: - Destinations

    func addDestination(_ destination: Destination) {
        destinations.insert(destination, at: 0)
        ReminderService.syncReminder(for: destination)
        recordActivity()
        checkAchievements()
        save()
    }

    func updateDestination(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        destinations[index] = destination
        ReminderService.syncReminder(for: destination)
        recordActivity()
        checkAchievements()
        save()
    }

    func deleteDestination(_ destination: Destination) {
        ReminderService.cancelReminder(for: destination.id)
        TripPhotoStore.deleteAll(for: destination.id)
        destinations.removeAll { $0.id == destination.id }
        checklistItems.removeAll { $0.destinationTag == destination.name }
        recordActivity()
        checkAchievements()
        save()
    }

    func toggleVisited(for destination: Destination) {
        guard var updated = destinations.first(where: { $0.id == destination.id }) else { return }
        updated.visited.toggle()
        updateDestination(updated)
        if updated.visited {
            FeedbackHelper.success()
        } else {
            FeedbackHelper.tap()
        }
    }

    var nextUpcomingDestination: Destination? {
        destinations
            .filter { !$0.visited }
            .sorted { $0.plannedDate < $1.plannedDate }
            .first { ($0.daysUntilTrip ?? 0) >= 0 }
    }

    var rouletteCandidates: [Destination] {
        destinations.filter { !$0.visited }
    }

    // MARK: - Checklist

    func addChecklistItem(_ item: ChecklistItem) {
        checklistItems.insert(item, at: 0)
        recordActivity()
        checkAchievements()
        save()
    }

    func updateChecklistItem(_ item: ChecklistItem) {
        guard let index = checklistItems.firstIndex(where: { $0.id == item.id }) else { return }
        checklistItems[index] = item
        recordActivity()
        checkAchievements()
        save()
    }

    func deleteChecklistItem(_ item: ChecklistItem) {
        checklistItems.removeAll { $0.id == item.id }
        recordActivity()
        checkAchievements()
        save()
    }

    func toggleChecklistItem(_ item: ChecklistItem) {
        guard var updated = checklistItems.first(where: { $0.id == item.id }) else { return }
        updated.completed.toggle()
        updateChecklistItem(updated)
        if updated.completed {
            FeedbackHelper.success()
        } else {
            FeedbackHelper.tap()
        }
    }

    func createPackingList(for destination: Destination) {
        let defaults: [(String, ChecklistKind)] = [
            ("Passport & ID", .packing),
            ("Travel adapter", .packing),
            ("Comfortable shoes", .packing),
            ("Phone charger", .packing),
            ("Book flight to \(destination.name)", .itinerary),
            ("Reserve accommodation", .itinerary),
            ("Plan day 1 activities", .itinerary)
        ]

        for (title, kind) in defaults {
            let item = ChecklistItem(
                title: title,
                category: kind,
                destinationTag: destination.name
            )
            checklistItems.insert(item, at: 0)
        }

        recordActivity()
        checkAchievements()
        save()
        FeedbackHelper.save()
    }

    func applyPackingTemplate(_ template: PackingTemplate, to destinationName: String) {
        for title in template.items {
            let alreadyExists = checklistItems.contains {
                $0.title == title && $0.destinationTag == destinationName && $0.category == .packing
            }
            guard !alreadyExists else { continue }
            let item = ChecklistItem(
                title: title,
                category: .packing,
                destinationTag: destinationName
            )
            checklistItems.insert(item, at: 0)
        }
        recordActivity()
        checkAchievements()
        save()
        FeedbackHelper.save()
    }

    func items(for kind: ChecklistKind, destinationFilter: String? = nil) -> [ChecklistItem] {
        checklistItems.filter { item in
            item.category == kind &&
            (destinationFilter == nil || destinationFilter!.isEmpty || item.destinationTag == destinationFilter)
        }
    }

    var completedChecklistCount: Int {
        checklistItems.filter(\.completed).count
    }

    var visitedDestinationCount: Int {
        destinations.filter(\.visited).count
    }

    // MARK: - Phrases

    func toggleFavouritePhrase(_ phraseID: String) {
        if favouritePhraseIDs.contains(phraseID) {
            favouritePhraseIDs.removeAll { $0 == phraseID }
        } else {
            favouritePhraseIDs.append(phraseID)
        }
        recordActivity()
        save()
    }

    func isFavouritePhrase(_ phraseID: String) -> Bool {
        favouritePhraseIDs.contains(phraseID)
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity()
        save()
    }

    // MARK: - Reset

    static func resetAllData() {
        for destination in AppDataStore.shared.destinations {
            ReminderService.cancelReminder(for: destination.id)
            TripPhotoStore.deleteAll(for: destination.id)
        }
        UserDefaults.standard.removeObject(forKey: storageKey)
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadAfterReset() {
        hasSeenOnboarding = false
        destinations = []
        checklistItems = []
        favouritePhraseIDs = []
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = []
        newlyUnlockedAchievement = nil
        selectedTab = .bucket
        soundEnabled = true
        hapticEnabled = true
    }

    // MARK: - Activity & Streak

    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
        checkAchievements()
    }

    func dismissAchievementBanner() {
        newlyUnlockedAchievement = nil
    }

    // MARK: - Achievements

    func checkAchievements() {
        let destinationCount = destinations.count
        let visitedCount = visitedDestinationCount
        let itemCount = checklistItems.count
        let completedCount = completedChecklistCount

        for achievement in AchievementDefinition.all {
            guard !achievementsUnlocked.contains(achievement.id) else { continue }
            if achievement.isUnlocked(
                destinations: destinationCount,
                visitedDestinations: visitedCount,
                checklistItems: itemCount,
                checklistsCompleted: completedCount,
                streakDays: streakDays
            ) {
                achievementsUnlocked.append(achievement.id)
                newlyUnlockedAchievement = achievement
                FeedbackHelper.success()
            }
        }
    }

    var unlockedAchievements: [AchievementDefinition] {
        AchievementDefinition.all.filter { achievementsUnlocked.contains($0.id) }
    }

    // MARK: - Reminders

    private func syncAllReminders() {
        for destination in destinations {
            ReminderService.syncReminder(for: destination)
        }
    }

    // MARK: - Persistence

    private func save() {
        let data = PersistedData(
            hasSeenOnboarding: hasSeenOnboarding,
            destinations: destinations,
            checklistItems: checklistItems,
            favouritePhraseIDs: favouritePhraseIDs,
            streakDays: streakDays,
            lastActivityDate: lastActivityDate,
            achievementsUnlocked: achievementsUnlocked,
            soundEnabled: soundEnabled,
            hapticEnabled: hapticEnabled
        )

        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: Self.storageKey),
              let data = try? JSONDecoder().decode(PersistedData.self, from: raw) else { return }

        hasSeenOnboarding = data.hasSeenOnboarding
        destinations = data.destinations
        checklistItems = data.checklistItems
        favouritePhraseIDs = data.favouritePhraseIDs
        streakDays = data.streakDays
        lastActivityDate = data.lastActivityDate
        achievementsUnlocked = data.achievementsUnlocked
        soundEnabled = data.soundEnabled ?? true
        hapticEnabled = data.hapticEnabled ?? true
    }
}
