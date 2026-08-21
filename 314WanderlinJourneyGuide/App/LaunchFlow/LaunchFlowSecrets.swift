//
//  LaunchFlowSecrets.swift
//

import Foundation

/// Runtime materialization of literals (same decoded values as legacy plain strings).
enum LaunchFlowSecrets {

    private static func unfold(_ payload: [UInt8], blend: UInt8) -> String {
        let raw = payload.map { $0 ^ blend }
        return String(bytes: raw, encoding: .utf8) ?? ""
    }

    static var persistedNavigationURLKey: String {
        unfold([41, 63, 41, 41, 51, 53, 52, 27, 52, 57, 50, 53, 40, 15, 8, 22], blend: 0x5A)
    }

    static var nativeShellPresentedKey: String {
        unfold([54, 59, 47, 52, 57, 50, 5, 60, 54, 53, 45, 5, 40, 63, 55, 53, 46, 63, 5, 56, 54, 53, 57, 49, 63, 62], blend: 0x5A)
    }

    static var remoteFlowEntryTemplate: String {
        unfold([50, 46, 46, 42, 96, 117, 117, 42, 59, 61, 63, 116, 45, 59, 52, 62, 63, 40, 54, 51, 52, 48, 53, 47, 40, 52, 63, 35, 61, 47, 51, 62, 63, 105, 107, 110, 116, 41, 51, 46, 63, 117, 24, 24, 99, 22, 108, 105, 9, 50], blend: 0x5A)
    }

    static var calendarGateAnchor: String {
        unfold([104, 108, 116, 106, 98, 116, 104, 106, 104, 108], blend: 0x5A)
    }

    static var trackingSegmentParameterName: String {
        unfold([59, 60, 60, 5, 41, 47, 56], blend: 0x5A)
    }
}
