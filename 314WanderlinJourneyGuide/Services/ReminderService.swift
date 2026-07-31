import Foundation
import UserNotifications

enum ReminderService {
    private static let center = UNUserNotificationCenter.current()

    static func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    static func syncReminder(for destination: Destination) {
        cancelReminder(for: destination.id)

        guard destination.reminderEnabled, !destination.visited else { return }

        let calendar = Calendar.current
        guard let fireDate = calendar.date(
            byAdding: .day,
            value: -destination.reminderDaysBefore,
            to: calendar.startOfDay(for: destination.plannedDate)
        ) else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: fireDate)
        components.hour = 9
        components.minute = 0

        let triggerDate = calendar.date(from: components) ?? fireDate
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Pack for \(destination.name)"
        content.body = "Your trip is in \(destination.reminderDaysBefore) day\(destination.reminderDaysBefore == 1 ? "" : "s"). Check your packing list."
        content.sound = AppDataStore.shared.soundEnabled ? .default : nil

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationID(for: destination.id),
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    static func cancelReminder(for destinationID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: destinationID)])
    }

    static func cancelAll(for destinations: [Destination]) {
        let ids = destinations.map { notificationID(for: $0.id) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private static func notificationID(for destinationID: UUID) -> String {
        "packing-reminder-\(destinationID.uuidString)"
    }
}
