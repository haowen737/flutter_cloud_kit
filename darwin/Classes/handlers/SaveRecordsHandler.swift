import Foundation
import CloudKit

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

class SaveRecordsHandler {
    static func handle(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let recordsData = arguments["records"] as? [[String: Any]] else {
            return result(createFlutterError(message: "Invalid arguments for saveRecords"))
        }

        guard let database = getDatabaseFromArgs(arguments: arguments) else {
            return result(createFlutterError(message: "Cannot create a database for the provided scope"))
        }

        let records = recordsData.compactMap { createCKRecordFromArgs(arguments: $0) }
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .allKeys

        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            if let error = error {
                result(createFlutterError(message: error.localizedDescription))
            } else {
                let savedRecordIDs = savedRecords?.map { $0.recordID.recordName } ?? []
                result(savedRecordIDs)
            }
        }

        database.add(operation)
    }
}