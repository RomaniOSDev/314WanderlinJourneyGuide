import Foundation

enum ChecklistKind: String, Codable, CaseIterable, Identifiable {
    case packing
    case itinerary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .packing: return "Packing"
        case .itinerary: return "Itinerary"
        }
    }
}

struct ChecklistItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var category: ChecklistKind
    var destinationTag: String
    var completed: Bool

    init(
        id: UUID = UUID(),
        title: String,
        category: ChecklistKind,
        destinationTag: String = "",
        completed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.destinationTag = destinationTag
        self.completed = completed
    }
}
