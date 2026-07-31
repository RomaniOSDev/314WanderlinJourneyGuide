import Foundation
import UIKit

enum TripPhotoStore {
    private static var rootURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("TripPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    static func save(imageData: Data, destinationID: UUID) -> String? {
        let destinationFolder = rootURL.appendingPathComponent(destinationID.uuidString, isDirectory: true)
        if !FileManager.default.fileExists(atPath: destinationFolder.path) {
            try? FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
        }

        let photoID = UUID().uuidString
        let fileURL = destinationFolder.appendingPathComponent("\(photoID).jpg")
        do {
            try imageData.write(to: fileURL, options: .atomic)
            return photoID
        } catch {
            return nil
        }
    }

    static func load(photoID: String, destinationID: UUID) -> UIImage? {
        let fileURL = rootURL
            .appendingPathComponent(destinationID.uuidString, isDirectory: true)
            .appendingPathComponent("\(photoID).jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    static func delete(photoID: String, destinationID: UUID) {
        let fileURL = rootURL
            .appendingPathComponent(destinationID.uuidString, isDirectory: true)
            .appendingPathComponent("\(photoID).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }

    static func deleteAll(for destinationID: UUID) {
        let folder = rootURL.appendingPathComponent(destinationID.uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: folder)
    }
}
