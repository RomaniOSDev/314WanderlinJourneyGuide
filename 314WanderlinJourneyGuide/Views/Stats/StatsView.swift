import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var visitSlices: [StatSlice] {
        let visited = store.visitedDestinationCount
        let planned = max(store.destinations.count - visited, 0)
        return [
            StatSlice(label: "Visited", value: visited, color: Color("AppPrimary")),
            StatSlice(label: "Planned", value: planned, color: Color("AppAccent"))
        ]
    }

    private var checklistSlices: [StatSlice] {
        let packingDone = store.checklistItems.filter { $0.category == .packing && $0.completed }.count
        let packingLeft = store.checklistItems.filter { $0.category == .packing && !$0.completed }.count
        let itineraryDone = store.checklistItems.filter { $0.category == .itinerary && $0.completed }.count
        let itineraryLeft = store.checklistItems.filter { $0.category == .itinerary && !$0.completed }.count
        return [
            StatSlice(label: "Pack done", value: packingDone, color: Color("AppPrimary")),
            StatSlice(label: "Pack left", value: packingLeft, color: Color("AppPrimary").opacity(0.35)),
            StatSlice(label: "Plan done", value: itineraryDone, color: Color("AppAccent")),
            StatSlice(label: "Plan left", value: itineraryLeft, color: Color("AppAccent").opacity(0.35))
        ]
    }

    private var monthlyBars: [MonthBar] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        var counts: [Date: Int] = [:]
        for destination in store.destinations {
            let comps = calendar.dateComponents([.year, .month], from: destination.plannedDate)
            if let month = calendar.date(from: comps) {
                counts[month, default: 0] += 1
            }
        }

        return counts.keys.sorted().suffix(6).map { month in
            MonthBar(
                label: formatter.string(from: month),
                value: counts[month] ?? 0,
                month: month
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    overviewCards
                    visitChartCard
                    checklistChartCard
                    timelineChartCard
                    achievementsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 80)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .withScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var overviewCards: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            metricTile(title: "Destinations", value: "\(store.destinations.count)", icon: "mappin.and.ellipse")
            metricTile(title: "Visited", value: "\(store.visitedDestinationCount)", icon: "checkmark.seal.fill")
            metricTile(title: "Completed", value: "\(store.completedChecklistCount)", icon: "checklist")
            metricTile(title: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
        }
    }

    private func metricTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface").opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var visitChartCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 14) {
                chartTitle("Trip Status", icon: "globe.americas.fill")

                if store.destinations.isEmpty {
                    emptyChartHint("Add destinations to see visit progress.")
                } else {
                    Chart(visitSlices) { slice in
                        BarMark(
                            x: .value("Status", slice.label),
                            y: .value("Count", slice.value)
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(8)
                    }
                    .frame(height: 180)

                    HStack(spacing: 16) {
                        ForEach(visitSlices) { slice in
                            legendDot(color: slice.color, label: "\(slice.label) · \(slice.value)")
                        }
                    }
                }
            }
        }
    }

    private var checklistChartCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 14) {
                chartTitle("Checklist Progress", icon: "checklist")

                if store.checklistItems.isEmpty {
                    emptyChartHint("Create packing or itinerary items to track progress.")
                } else {
                    Chart(checklistSlices) { slice in
                        BarMark(
                            x: .value("Count", slice.value),
                            y: .value("Type", slice.label)
                        )
                        .foregroundStyle(slice.color)
                        .cornerRadius(6)
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                }
            }
        }
    }

    private var timelineChartCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 14) {
                chartTitle("Planned by Month", icon: "calendar")

                if monthlyBars.isEmpty {
                    emptyChartHint("Your upcoming trip timeline will appear here.")
                } else {
                    Chart(monthlyBars) { bar in
                        BarMark(
                            x: .value("Month", bar.label),
                            y: .value("Trips", bar.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                    .frame(height: 180)
                }
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image("DecorBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("\(store.unlockedAchievements.count)/\(AchievementDefinition.all.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
            }

            ProgressView(
                value: Double(store.unlockedAchievements.count),
                total: Double(max(AchievementDefinition.all.count, 1))
            )
            .tint(Color("AppPrimary"))

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(AchievementDefinition.all) { achievement in
                    achievementCard(achievement)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("AppSurface").opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func chartTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    private func emptyChartHint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            .multilineTextAlignment(.center)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }

    @ViewBuilder
    private func achievementCard(_ achievement: AchievementDefinition) -> some View {
        let unlocked = store.achievementsUnlocked.contains(achievement.id)

        VStack(spacing: 10) {
            Text(achievement.emoji)
                .font(.system(size: 32))
                .opacity(unlocked ? 1 : 0.35)

            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .font(.caption)
                .foregroundStyle(unlocked ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.5))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    unlocked
                        ? Color("AppPrimary").opacity(0.12)
                        : Color.black.opacity(0.18)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            unlocked ? Color("AppPrimary").opacity(0.35) : Color.white.opacity(0.06),
                            lineWidth: 1
                        )
                )
        )
    }
}

private struct StatSlice: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    let color: Color
}

private struct MonthBar: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    let month: Date
}
