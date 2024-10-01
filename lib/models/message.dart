// Community Member
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bruceboard/models/firestoredoc.dart';

class Message implements FirestoreDoc {
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextMeid';
  @override
  // final String totalField = 'NO-TOTALS';
  final String totalField = 'noMessages';

  final NumberFormat _keyFormat = NumberFormat("ME00000000", "en_US");
  // Document Specific Data items
  int pidFrom;
  int pidTo;
  int messageCode;
  int messageType;
  Timestamp timestamp; // Time the class was created
  Map<String, dynamic> data = {};
  String comment;
  String description;

  Message({ required Map<String, dynamic> data }) :
        docId = data['docId'] ?? -1,
        pidFrom = data['pidFrom'] ?? -1,
        pidTo = data['pidTo'] ?? -1,
        messageCode = data['messageCode'] ?? -1,
        messageType = data['messageType'] ?? -1,
        timestamp = data['timestamp'] ?? Timestamp.now(),
        data = data['data'] ?? {},
        description = data['description'] ?? 'No Message Description',
        comment = data['comment'] ?? 'No Message Comment Provided';

  @override
  void update({ required Map<String, dynamic> data, updateTimestamp }) {
    docId = data['docId'] ?? docId;  // From Super
    pidFrom = data['pidFrom'] ?? pidFrom;
    pidTo = data['pidTo'] ?? pidTo;
    messageCode = data['messageType'] ?? messageCode;
    messageType = data['messageType'] ?? messageType;
    timestamp = data['timestamp'] ?? timestamp;
    data = data['data'] ?? data;
    description = data['description'] ?? description;
    comment = data['comment'] ?? comment;
  }

  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving message $key", name: '${runtimeType.toString()}:key');
    return key;
  }

  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'pidFrom': pidFrom,
      'pidTo': pidTo,
      'messageCode': messageCode,
      'messageType': messageType,
      'timestamp': timestamp,
      'data': data,
      'description': description,
      'comment': comment,
    };
  }
}