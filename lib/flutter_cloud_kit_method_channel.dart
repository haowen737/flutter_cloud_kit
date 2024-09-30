import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cloud_kit/types/cloud_ket_record.dart';
import 'package:flutter_cloud_kit/types/cloud_kit_account_status.dart';
import 'package:flutter_cloud_kit/types/database_scope.dart';

import 'flutter_cloud_kit_platform_interface.dart';

/// An implementation of [FlutterCloudKitPlatform] that uses method channels.
class MethodChannelFlutterCloudKit extends FlutterCloudKitPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('app.fuelet.flutter_cloud_kit');

  @override
  Future<CloudKitAccountStatus> getAccountStatus({String? containerId}) async {
    final args = containerId == null ? {} : {'containerId': containerId};
    int rawStatus = await methodChannel.invokeMethod('getAccountStatus', args);
    try {
      return CloudKitAccountStatus.values[rawStatus];
    } catch (_) {
      return CloudKitAccountStatus.unknown;
    }
  }

  @override
  Future<List<String>> saveRecords({
    String? containerId,
    required CloudKitDatabaseScope scope,
    required List<Map<String, dynamic>> records,
  }) async {
    var args = {
      'databaseScope': scope.name,
      'records': records,
    };
    if (containerId != null) {
      args['containerId'] = containerId;
    }

    List<Object?> result =
        await methodChannel.invokeMethod('saveRecords', args);
    return result.cast<String>();
  }

  @override
  Future<void> saveRecord(
      {String? containerId,
      required CloudKitDatabaseScope scope,
      required String recordType,
      required Map<String, String> record,
      String? recordName}) async {
    var args = {
      'databaseScope': scope.name,
      'recordType': recordType,
      'record': record
    };
    if (containerId != null) {
      args['containerId'] = containerId;
    }
    if (recordName != null) {
      args['recordName'] = recordName;
    }
    await methodChannel.invokeMethod('saveRecord', args);
  }

  @override
  Future<CloudKitRecord> getRecord(
      {String? containerId,
      required CloudKitDatabaseScope scope,
      required String recordName}) async {
    var args = {
      'databaseScope': scope.name,
      'recordName': recordName,
    };
    if (containerId != null) {
      args['containerId'] = containerId;
    }
    Map<Object?, Object?> result =
        await methodChannel.invokeMethod('getRecord', args);

    return CloudKitRecord.fromMap(result);
  }

  @override
  Future<List<CloudKitRecord>> getRecordsByType(
      {String? containerId,
      required CloudKitDatabaseScope scope,
      required String recordType}) async {
    var args = {
      'databaseScope': scope.name,
      'recordType': recordType,
    };
    if (containerId != null) {
      args['containerId'] = containerId;
    }

    List<Object?> result =
        await methodChannel.invokeMethod('getRecordsByType', args);

    try {
      return result
          .map((e) => e as Map<Object?, Object?>)
          .map(CloudKitRecord.fromMap)
          .toList();
    } catch (e) {
      throw Exception('Cannot parse cloud kit response: $e');
    }
  }

  @override
  Future<void> deleteRecord(
      {String? containerId,
      required CloudKitDatabaseScope scope,
      required String recordName}) async {
    var args = {
      'databaseScope': scope.name,
      'recordName': recordName,
    };
    if (containerId != null) {
      args['containerId'] = containerId;
    }
    await methodChannel.invokeMethod('deleteRecord', args);
  }
}
