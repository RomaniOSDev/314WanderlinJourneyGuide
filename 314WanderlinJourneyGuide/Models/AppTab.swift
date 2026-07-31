import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case bucket
    case packing
    case stats
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .bucket: return "Bucket"
        case .packing: return "Packing"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .bucket: return "suitcase.fill"
        case .packing: return "checklist"
        case .stats: return "chart.xyaxis.line"
        case .settings: return "gearshape.fill"
        }
    }
}
