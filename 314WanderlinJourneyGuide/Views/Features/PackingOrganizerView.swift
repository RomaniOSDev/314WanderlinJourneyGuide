import SwiftUI

struct PackingOrganizerView: View {
    @EnvironmentObject var store: AppDataStore
    @State private var selectedKind: ChecklistKind = .packing
    @State private var selectedDestinationFilter = ""
    @State private var showAddSheet = false
    @State private var newItemTitle = ""

    private var filteredItems: [ChecklistItem] {
        store.items(for: selectedKind, destinationFilter: selectedDestinationFilter.isEmpty ? nil : selectedDestinationFilter)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    Picker("Category", selection: $selectedKind) {
                        ForEach(ChecklistKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    if !store.destinations.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                DestinationChip(
                                    title: "All",
                                    isSelected: selectedDestinationFilter.isEmpty
                                ) {
                                    FeedbackHelper.tap()
                                    selectedDestinationFilter = ""
                                }

                                ForEach(store.destinations) { destination in
                                    DestinationChip(
                                        title: destination.name,
                                        isSelected: selectedDestinationFilter == destination.name
                                    ) {
                                        FeedbackHelper.tap()
                                        selectedDestinationFilter = destination.name
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }

                    if selectedKind == .packing {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(PackingTemplate.allCases) { template in
                                    Button {
                                        FeedbackHelper.tap()
                                        applyTemplate(template)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: template.iconName)
                                                .font(.caption2)
                                            Text(template.title)
                                                .font(.caption.weight(.semibold))
                                        }
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color("AppSurface").opacity(0.85))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color("AppPrimary").opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    }

                    if filteredItems.isEmpty {
                        Spacer()
                        EmptyStateView(
                            systemImage: selectedKind == .packing ? "suitcase" : "list.bullet.clipboard",
                            message: selectedKind == .packing
                                ? "No packing items yet. Tap a template or + to add essentials."
                                : "No itinerary items yet. Tap + to plan your trip."
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredItems) { item in
                                    ChecklistRow(item: item) {
                                        store.toggleChecklistItem(item)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            FeedbackHelper.delete()
                                            store.deleteChecklistItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }

                FloatingActionButton {
                    showAddSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 110)
            }
            .dismissKeyboardOnTap()
            .navigationTitle("Trip Organizer")
            .navigationBarTitleDisplayMode(.large)
            .withScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
            .alert("New Item", isPresented: $showAddSheet) {
                TextField("Item title", text: $newItemTitle)
                Button("Cancel", role: .cancel) {
                    newItemTitle = ""
                }
                Button("Add") {
                    let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    let item = ChecklistItem(
                        title: title,
                        category: selectedKind,
                        destinationTag: selectedDestinationFilter
                    )
                    store.addChecklistItem(item)
                    FeedbackHelper.save()
                    newItemTitle = ""
                }
            } message: {
                Text("Enter a \(selectedKind.title.lowercased()) item.")
            }
        }
    }

    private func applyTemplate(_ template: PackingTemplate) {
        if !selectedDestinationFilter.isEmpty {
            store.applyPackingTemplate(template, to: selectedDestinationFilter)
            return
        }

        if store.destinations.count == 1, let only = store.destinations.first {
            store.applyPackingTemplate(template, to: only.name)
            selectedDestinationFilter = only.name
            return
        }

        if store.destinations.isEmpty {
            store.applyPackingTemplate(template, to: "")
            return
        }

        // Prefer first destination when "All" is selected
        if let first = store.destinations.first {
            store.applyPackingTemplate(template, to: first.name)
            selectedDestinationFilter = first.name
        }
    }
}
