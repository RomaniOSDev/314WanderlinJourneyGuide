import PhotosUI
import SwiftUI

struct DestinationDetailView: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let destination: Destination

    @State private var editedDestination: Destination
    @State private var showAddTimeline = false
    @State private var timelineTitle = ""
    @State private var timelineSlot: DaySlot = .morning
    @State private var timelineDay = 1
    @State private var showAddBudget = false
    @State private var budgetTitle = ""
    @State private var budgetAmountText = ""
    @State private var budgetLimitText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showTemplateSheet = false

    init(destination: Destination) {
        self.destination = destination
        _editedDestination = State(initialValue: destination)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    headerCard
                    tagsCard
                    reminderCard
                    budgetCard
                    timelineCard
                    photoCard
                    packingActions
                    linkedItems
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .withScreenBackground()
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            store.toggleVisited(for: editedDestination)
                        } label: {
                            Label(
                                editedDestination.visited ? "Mark Unvisited" : "Mark Visited",
                                systemImage: editedDestination.visited ? "xmark.circle" : "checkmark.circle"
                            )
                        }

                        Button(role: .destructive) {
                            FeedbackHelper.delete()
                            store.deleteDestination(editedDestination)
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .onReceive(store.$destinations) { destinations in
                if let updated = destinations.first(where: { $0.id == destination.id }) {
                    editedDestination = updated
                    budgetLimitText = editedDestination.budgetLimit > 0
                        ? PlainAmount.text(editedDestination.budgetLimit)
                        : ""
                }
            }
            .onAppear {
                budgetLimitText = editedDestination.budgetLimit > 0
                    ? PlainAmount.text(editedDestination.budgetLimit)
                    : ""
            }
            .onChange(of: selectedPhoto) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let photoID = TripPhotoStore.save(imageData: data, destinationID: editedDestination.id) {
                        editedDestination.photoIDs.insert(photoID, at: 0)
                        persist()
                        FeedbackHelper.save()
                    }
                    await MainActor.run { selectedPhoto = nil }
                }
            }
            .alert("Timeline Stop", isPresented: $showAddTimeline) {
                TextField("Activity", text: $timelineTitle)
                Button("Cancel", role: .cancel) { timelineTitle = "" }
                Button("Add") {
                    let title = timelineTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title.isEmpty else { return }
                    let item = TimelineItem(title: title, slot: timelineSlot, dayNumber: timelineDay)
                    editedDestination.timelineItems.append(item)
                    persist()
                    FeedbackHelper.save()
                    timelineTitle = ""
                }
            } message: {
                Text("Day \(timelineDay) · \(timelineSlot.title)")
            }
            .alert("Budget Entry", isPresented: $showAddBudget) {
                TextField("What for", text: $budgetTitle)
                TextField("Amount", text: $budgetAmountText)
                    .keyboardType(.decimalPad)
                Button("Cancel", role: .cancel) {
                    budgetTitle = ""
                    budgetAmountText = ""
                }
                Button("Add") {
                    let title = budgetTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let normalized = budgetAmountText.replacingOccurrences(of: ",", with: ".")
                    guard !title.isEmpty, let amount = Double(normalized), amount > 0 else { return }
                    editedDestination.budgetEntries.insert(
                        BudgetEntry(title: title, amount: amount),
                        at: 0
                    )
                    persist()
                    FeedbackHelper.save()
                    budgetTitle = ""
                    budgetAmountText = ""
                }
            } message: {
                Text("Enter a plain number for the amount.")
            }
            .confirmationDialog("Packing Template", isPresented: $showTemplateSheet, titleVisibility: .visible) {
                ForEach(PackingTemplate.allCases) { template in
                    Button(template.title) {
                        store.applyPackingTemplate(template, to: editedDestination.name)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var headerCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title)
                        .foregroundStyle(Color("AppPrimary"))
                    VStack(alignment: .leading) {
                        Text(editedDestination.name)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(editedDestination.country)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    if editedDestination.visited {
                        Label("Visited", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                Divider().overlay(Color.white.opacity(0.08))

                Label {
                    Text(editedDestination.plannedDate, style: .date)
                        .foregroundStyle(Color("AppTextPrimary"))
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("AppPrimary"))
                }
                .font(.subheadline)

                if let days = editedDestination.daysUntilTrip, !editedDestination.visited {
                    Label {
                        Text(countdownText(days))
                            .foregroundStyle(Color("AppAccent"))
                    } icon: {
                        Image(systemName: "hourglass")
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .font(.subheadline.weight(.semibold))
                }

                if !editedDestination.notes.isEmpty {
                    Text(editedDestination.notes)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private var tagsCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Tags", icon: "tag.fill")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(TripTag.allCases) { tag in
                        let selected = editedDestination.tags.contains(tag)
                        Button {
                            FeedbackHelper.tap()
                            if selected {
                                editedDestination.tags.removeAll { $0 == tag }
                            } else {
                                editedDestination.tags.append(tag)
                            }
                            persist()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tag.iconName)
                                    .font(.caption2)
                                Text(tag.title)
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(selected ? Color("AppBackground") : Color("AppTextPrimary"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule().fill(
                                    selected
                                        ? AnyShapeStyle(Color("AppPrimary"))
                                        : AnyShapeStyle(Color.black.opacity(0.2))
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var reminderCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Packing Reminder", icon: "bell.fill")

                Toggle(isOn: Binding(
                    get: { editedDestination.reminderEnabled },
                    set: { value in
                        editedDestination.reminderEnabled = value
                        if value {
                            ReminderService.requestAuthorizationIfNeeded()
                        }
                        persist()
                        FeedbackHelper.tap()
                    }
                )) {
                    Text("Remind me before the trip")
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .tint(Color("AppPrimary"))

                if editedDestination.reminderEnabled {
                    Stepper(value: Binding(
                        get: { editedDestination.reminderDaysBefore },
                        set: { value in
                            editedDestination.reminderDaysBefore = value
                            persist()
                        }
                    ), in: 1...30) {
                        Text("\(editedDestination.reminderDaysBefore) day\(editedDestination.reminderDaysBefore == 1 ? "" : "s") before")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
    }

    private var budgetCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Trip Budget", icon: "chart.pie.fill")

                HStack {
                    Text("Limit")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    TextField("0", text: $budgetLimitText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: 120)
                        .onChange(of: budgetLimitText) { newValue in
                            let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                            editedDestination.budgetLimit = Double(normalized) ?? 0
                        }
                        .onSubmit { persist() }
                }

                Button("Save Limit") {
                    persist()
                    FeedbackHelper.save()
                    KeyboardDismiss.hide()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppPrimary"))

                HStack {
                    budgetStat(title: "Spent", value: editedDestination.budgetSpent)
                    budgetStat(title: "Left", value: editedDestination.budgetRemaining)
                }

                if editedDestination.budgetLimit > 0 {
                    ProgressView(
                        value: min(editedDestination.budgetSpent, editedDestination.budgetLimit),
                        total: max(editedDestination.budgetLimit, 1)
                    )
                    .tint(editedDestination.budgetRemaining < 0 ? Color.red : Color("AppPrimary"))
                }

                ForEach(editedDestination.budgetEntries) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(entry.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                        Text(PlainAmount.text(entry.amount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            editedDestination.budgetEntries.removeAll { $0.id == entry.id }
                            persist()
                            FeedbackHelper.delete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                Button {
                    FeedbackHelper.tap()
                    showAddBudget = true
                } label: {
                    Label("Add Entry", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private var timelineCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    sectionTitle("Day Timeline", icon: "list.bullet.rectangle")
                    Spacer()
                    Menu {
                        Picker("Slot", selection: $timelineSlot) {
                            ForEach(DaySlot.allCases) { slot in
                                Text(slot.title).tag(slot)
                            }
                        }
                        Stepper("Day \(timelineDay)", value: $timelineDay, in: 1...14)
                        Button("Add Stop") {
                            showAddTimeline = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                if editedDestination.timelineItems.isEmpty {
                    Text("Plan morning, afternoon, and evening stops for each day.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    let grouped = Dictionary(grouping: editedDestination.timelineItems.sorted {
                        if $0.dayNumber == $1.dayNumber {
                            return slotOrder($0.slot) < slotOrder($1.slot)
                        }
                        return $0.dayNumber < $1.dayNumber
                    }, by: \.dayNumber)

                    ForEach(grouped.keys.sorted(), id: \.self) { day in
                        Text("Day \(day)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.top, 4)

                        ForEach(grouped[day] ?? []) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: item.slot.iconName)
                                    .foregroundStyle(Color("AppPrimary"))
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(item.slot.title)
                                        .font(.caption2)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                                Spacer()
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    editedDestination.timelineItems.removeAll { $0.id == item.id }
                                    persist()
                                    FeedbackHelper.delete()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var photoCard: some View {
        GradientCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    sectionTitle("Photo Journal", icon: "photo.on.rectangle")
                    Spacer()
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                if editedDestination.photoIDs.isEmpty {
                    Text("Save trip memories here.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(editedDestination.photoIDs, id: \.self) { photoID in
                                if let image = TripPhotoStore.load(photoID: photoID, destinationID: editedDestination.id) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                TripPhotoStore.delete(photoID: photoID, destinationID: editedDestination.id)
                                                editedDestination.photoIDs.removeAll { $0 == photoID }
                                                persist()
                                                FeedbackHelper.delete()
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var packingActions: some View {
        VStack(spacing: 10) {
            Button {
                FeedbackHelper.save()
                store.createPackingList(for: editedDestination)
            } label: {
                actionLabel(title: "Create Packing List", icon: "checklist")
            }

            Button {
                FeedbackHelper.tap()
                showTemplateSheet = true
            } label: {
                actionLabel(title: "Apply Packing Template", icon: "square.stack.3d.up.fill", outlined: true)
            }
        }
    }

    private var linkedItems: some View {
        let relatedItems = store.checklistItems.filter { $0.destinationTag == editedDestination.name }
        return Group {
            if !relatedItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Linked Items")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))

                    LazyVStack(spacing: 10) {
                        ForEach(relatedItems) { item in
                            ChecklistRow(item: item) {
                                store.toggleChecklistItem(item)
                            }
                        }
                    }
                }
            }
        }
    }

    private func actionLabel(title: String, icon: String, outlined: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(outlined ? Color("AppPrimary") : Color("AppBackground"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    outlined
                        ? AnyShapeStyle(Color("AppSurface").opacity(0.8))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(outlined ? Color("AppPrimary").opacity(0.4) : Color.clear, lineWidth: 1)
                )
        )
    }

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    private func budgetStat(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(PlainAmount.text(value))
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.18))
        )
    }

    private func countdownText(_ days: Int) -> String {
        if days == 0 { return "Trip is today" }
        if days < 0 { return "\(-days) day\(-days == 1 ? "" : "s") ago" }
        return "\(days) day\(days == 1 ? "" : "s") to go"
    }

    private func slotOrder(_ slot: DaySlot) -> Int {
        switch slot {
        case .morning: return 0
        case .afternoon: return 1
        case .evening: return 2
        }
    }

    private func persist() {
        store.updateDestination(editedDestination)
    }
}
