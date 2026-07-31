import Foundation

enum TripTag: String, Codable, CaseIterable, Identifiable {
    case beach
    case city
    case mountains
    case nature
    case culture
    case food

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beach: return "Beach"
        case .city: return "City"
        case .mountains: return "Mountains"
        case .nature: return "Nature"
        case .culture: return "Culture"
        case .food: return "Food"
        }
    }

    var iconName: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .city: return "building.2.fill"
        case .mountains: return "triangle.fill"
        case .nature: return "leaf.fill"
        case .culture: return "building.columns.fill"
        case .food: return "fork.knife"
        }
    }
}

enum DaySlot: String, Codable, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }

    var iconName: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }
}

struct TimelineItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var slot: DaySlot
    var dayNumber: Int
    var notes: String

    init(
        id: UUID = UUID(),
        title: String,
        slot: DaySlot = .morning,
        dayNumber: Int = 1,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.slot = slot
        self.dayNumber = max(dayNumber, 1)
        self.notes = notes
    }
}

struct BudgetEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var amount: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.createdAt = createdAt
    }
}

enum PackingTemplate: String, CaseIterable, Identifiable {
    case beach
    case city
    case mountains

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beach: return "Beach"
        case .city: return "City"
        case .mountains: return "Mountains"
        }
    }

    var iconName: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .city: return "building.2.fill"
        case .mountains: return "triangle.fill"
        }
    }

    var items: [String] {
        switch self {
        case .beach:
            return [
                "Swimwear",
                "Sunscreen",
                "Beach towel",
                "Flip-flops",
                "Sunglasses",
                "Light cover-up",
                "Reusable water bottle"
            ]
        case .city:
            return [
                "Comfortable walking shoes",
                "City map offline",
                "Day backpack",
                "Portable charger",
                "Light jacket",
                "Transit cards / tickets",
                "Compact umbrella"
            ]
        case .mountains:
            return [
                "Hiking boots",
                "Layered clothing",
                "Rain shell",
                "Trail snacks",
                "Headlamp",
                "First-aid kit",
                "Reusable water bottle"
            ]
        }
    }
}
