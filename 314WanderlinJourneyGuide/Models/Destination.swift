import Foundation

struct Destination: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var country: String
    var plannedDate: Date
    var notes: String
    var visited: Bool
    var tags: [TripTag]
    var budgetLimit: Double
    var budgetEntries: [BudgetEntry]
    var photoIDs: [String]
    var timelineItems: [TimelineItem]
    var reminderEnabled: Bool
    var reminderDaysBefore: Int

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        plannedDate: Date = Date(),
        notes: String = "",
        visited: Bool = false,
        tags: [TripTag] = [],
        budgetLimit: Double = 0,
        budgetEntries: [BudgetEntry] = [],
        photoIDs: [String] = [],
        timelineItems: [TimelineItem] = [],
        reminderEnabled: Bool = false,
        reminderDaysBefore: Int = 3
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.plannedDate = plannedDate
        self.notes = notes
        self.visited = visited
        self.tags = tags
        self.budgetLimit = budgetLimit
        self.budgetEntries = budgetEntries
        self.photoIDs = photoIDs
        self.timelineItems = timelineItems
        self.reminderEnabled = reminderEnabled
        self.reminderDaysBefore = max(reminderDaysBefore, 1)
    }

    var budgetSpent: Double {
        budgetEntries.reduce(0) { $0 + $1.amount }
    }

    var budgetRemaining: Double {
        budgetLimit - budgetSpent
    }

    var daysUntilTrip: Int? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tripDay = calendar.startOfDay(for: plannedDate)
        let days = calendar.dateComponents([.day], from: today, to: tripDay).day ?? 0
        return days
    }

    enum CodingKeys: String, CodingKey {
        case id, name, country, plannedDate, notes, visited
        case tags, budgetLimit, budgetEntries, photoIDs, timelineItems
        case reminderEnabled, reminderDaysBefore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        plannedDate = try container.decode(Date.self, forKey: .plannedDate)
        notes = try container.decode(String.self, forKey: .notes)
        visited = try container.decode(Bool.self, forKey: .visited)
        tags = try container.decodeIfPresent([TripTag].self, forKey: .tags) ?? []
        budgetLimit = try container.decodeIfPresent(Double.self, forKey: .budgetLimit) ?? 0
        budgetEntries = try container.decodeIfPresent([BudgetEntry].self, forKey: .budgetEntries) ?? []
        photoIDs = try container.decodeIfPresent([String].self, forKey: .photoIDs) ?? []
        timelineItems = try container.decodeIfPresent([TimelineItem].self, forKey: .timelineItems) ?? []
        reminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .reminderEnabled) ?? false
        reminderDaysBefore = try container.decodeIfPresent(Int.self, forKey: .reminderDaysBefore) ?? 3
    }
}
