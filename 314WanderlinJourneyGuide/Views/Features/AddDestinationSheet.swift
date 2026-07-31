import SwiftUI

struct AddDestinationSheet: View {
    @EnvironmentObject var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var country = ""
    @State private var plannedDate = Date()
    @State private var notes = ""
    @State private var selectedTags: Set<TripTag> = []
    @State private var reminderEnabled = false
    @State private var reminderDaysBefore = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("Destination") {
                    TextField("City or place name", text: $name)
                    TextField("Country", text: $country)
                    DatePicker("Planned date", selection: $plannedDate, displayedComponents: .date)
                }

                Section("Tags") {
                    ForEach(TripTag.allCases) { tag in
                        Button {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        } label: {
                            HStack {
                                Label(tag.title, systemImage: tag.iconName)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                            }
                        }
                    }
                }

                Section("Packing Reminder") {
                    Toggle("Remind before trip", isOn: $reminderEnabled)
                    if reminderEnabled {
                        Stepper("\(reminderDaysBefore) day\(reminderDaysBefore == 1 ? "" : "s") before", value: $reminderDaysBefore, in: 1...30)
                    }
                }

                Section("Notes") {
                    TextField("Travel notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .withScreenBackground()
            .navigationTitle("New Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if reminderEnabled {
                            ReminderService.requestAuthorizationIfNeeded()
                        }
                        let destination = Destination(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            country: country.trimmingCharacters(in: .whitespacesAndNewlines),
                            plannedDate: plannedDate,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                            tags: Array(selectedTags),
                            reminderEnabled: reminderEnabled,
                            reminderDaysBefore: reminderDaysBefore
                        )
                        store.addDestination(destination)
                        FeedbackHelper.save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
