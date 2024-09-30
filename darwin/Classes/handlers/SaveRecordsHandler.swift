import Foundation
import CloudKit

class SaveRecordsHandler {
    static func handle(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let recordsData = arguments["records"] as? [[String: Any]] else {
            result(FlutterError(code: "InvalidArguments", message: "Invalid arguments for saveRecords", details: nil))
            return
        }

        let database = getDatabaseFromArgs(arguments: arguments)
        guard let database = database else {
            result(FlutterError(code: "InvalidDatabase", message: "Invalid database scope", details: nil))
            return
        }

        let records = recordsData.compactMap { createCKRecordFromArgs(arguments: $0) }

        database.save(records) { savedRecords, error in
            if let error = error {
                result(FlutterError(code: "SaveError", message: error.localizedDescription, details: nil))
            } else {
                let savedRecordIDs = savedRecords?.map { $0.recordID.recordName } ?? []
                result(savedRecordIDs)
            }
        }
    }
}