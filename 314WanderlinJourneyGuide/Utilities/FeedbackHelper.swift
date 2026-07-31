import AudioToolbox
import UIKit

enum FeedbackHelper {
    static func tap() {
        guard AppDataStore.shared.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func save() {
        if AppDataStore.shared.hapticEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        playSound(1104)
    }

    static func success() {
        if AppDataStore.shared.hapticEnabled {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        playSound(1057)
    }

    static func delete() {
        if AppDataStore.shared.hapticEnabled {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        playSound(1155)
    }

    private static func playSound(_ soundID: SystemSoundID) {
        guard AppDataStore.shared.soundEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }
}
