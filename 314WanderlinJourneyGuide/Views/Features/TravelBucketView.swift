import SwiftUI

struct TravelBucketView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var showAddSheet = false
    @State private var selectedDestination: Destination?
    @State private var showRoulette = false
    @State private var searchText = ""
    @State private var selectedTag: TripTag?

    private var filteredDestinations: [Destination] {
        store.destinations.filter { destination in
            let matchesSearch = searchText.isEmpty
                || destination.name.localizedCaseInsensitiveContains(searchText)
                || destination.country.localizedCaseInsensitiveContains(searchText)
                || destination.notes.localizedCaseInsensitiveContains(searchText)
            let matchesTag = selectedTag == nil || destination.tags.contains(selectedTag!)
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        TravelBannerHeader()
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        if let next = store.nextUpcomingDestination {
                            countdownCard(next)
                                .padding(.horizontal, 16)
                        }

                        searchAndFilters
                            .padding(.horizontal, 16)

                        actionRow
                            .padding(.horizontal, 16)

                        if !store.destinations.isEmpty {
                            destinationChips
                        }

                        if filteredDestinations.isEmpty {
                            EmptyStateView(
                                systemImage: store.destinations.isEmpty ? "suitcase.fill" : "magnifyingglass",
                                message: store.destinations.isEmpty
                                    ? "No destinations added yet. Tap + to start your journey wishlist."
                                    : "No trips match your search or tag filter."
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredDestinations) { destination in
                                    DestinationRow(
                                        destination: destination,
                                        onToggleVisited: {
                                            store.toggleVisited(for: destination)
                                        },
                                        onTap: {
                                            selectedDestination = destination
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 100)
                }
                .frame(maxWidth: .infinity)
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()

                FloatingActionButton {
                    showAddSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 110)
            }
            .navigationTitle("Travel Bucket")
            .navigationBarTitleDisplayMode(.large)
            .withScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddSheet) {
                AddDestinationSheet()
            }
            .sheet(item: $selectedDestination) { destination in
                DestinationDetailView(destination: destination)
            }
            .sheet(isPresented: $showRoulette) {
                RouletteSheet()
            }
            .onReceive(NotificationCenter.default.publisher(for: .openDestination)) { note in
                guard let idString = note.userInfo?["id"] as? String,
                      let id = UUID(uuidString: idString),
                      let destination = store.destinations.first(where: { $0.id == id }) else { return }
                selectedDestination = destination
            }
        }
    }

    private func countdownCard(_ destination: Destination) -> some View {
        GradientCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color("AppAccent").opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "hourglass")
                        .foregroundStyle(Color("AppAccent"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Trip")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(destination.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let days = destination.daysUntilTrip {
                        Text(days == 0 ? "Today" : "\(days) day\(days == 1 ? "" : "s") left")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                    }
                }

                Spacer()

                Button {
                    FeedbackHelper.tap()
                    selectedDestination = destination
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var searchAndFilters: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("AppTextSecondary"))
                TextField("Search trips", text: $searchText)
                    .foregroundStyle(Color("AppTextPrimary"))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AppSurface").opacity(0.75))
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "All", icon: "line.3.horizontal.decrease.circle", selected: selectedTag == nil) {
                        selectedTag = nil
                    }
                    ForEach(TripTag.allCases) { tag in
                        filterChip(title: tag.title, icon: tag.iconName, selected: selectedTag == tag) {
                            selectedTag = tag
                        }
                    }
                }
            }
        }
    }

    private func filterChip(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackHelper.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(selected ? Color("AppBackground") : Color("AppTextPrimary"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(
                    selected
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyShapeStyle(Color("AppSurface").opacity(0.8))
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button {
                FeedbackHelper.tap()
                showRoulette = true
            } label: {
                HStack {
                    Image(systemName: "dice.fill")
                    Text("Roulette")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface").opacity(0.75))
                )
            }
            .buttonStyle(.plain)
            .disabled(store.rouletteCandidates.isEmpty)
            .opacity(store.rouletteCandidates.isEmpty ? 0.5 : 1)

            NavigationLink {
                PhraseTranslatorView()
            } label: {
                HStack {
                    Image(systemName: "character.bubble.fill")
                    Text("Phrases")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface").opacity(0.75))
                )
            }
        }
    }

    private var destinationChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.destinations) { destination in
                    DestinationChip(
                        title: destination.name,
                        isSelected: selectedDestination?.id == destination.id
                    ) {
                        FeedbackHelper.tap()
                        selectedDestination = destination
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
