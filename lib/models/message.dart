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
  @override
  final NumberFormat _keyFormat = NumberFormat("ME00000000", "en_US");
  // Document Specific Data items
  // @override
  // int docId;
  int pidFrom;  // /Player/{UID-REC}/Message/{UID-SEND}/Incoming/{MSID-KEY}
  int pidTo;
  int messageType;
  int responseCode;
  Timestamp timestamp; // Time the class was created
  Map<String, dynamic> data = {};
  // Map<String, dynamic> respnose = {};
  String comment;
  String description;

  Message({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        pidFrom = data['pidFrom'] ?? -1,
        pidTo = data['pidTo'] ?? -1,
        messageType = data['messageType'] ?? -1,
        timestamp = data['timestamp'] ?? Timestamp.now(),
        data = data['data'] ?? {},
        responseCode = data['responseCode'] ?? -1,
        description = data['description'] ?? 'No Message Description',
        comment = data['comment'] ?? 'No Message Comment Provided';

  @override
  void update({ required Map<String, dynamic> data, updateTimestamp }) {
    docId = data['docId'] ?? docId;  // From Super
    pidFrom = data['pidFrom'] ?? pidFrom;
    pidTo = data['pidTo'] ?? pidTo;
    messageType = data['messageType'] ?? messageType;
    timestamp = data['timestamp'] ?? timestamp;
    data = data['data'] ?? data;
    responseCode = data['responseCode'] ?? responseCode;
    description = data['description'] ?? description;
    comment = data['comment'] ?? comment;
  }

  // static String KEY(int id) {
  //   NumberFormat intFormat = NumberFormat("MS00000000", "en_US");
  //   String key = intFormat.format(id);
  //   return key;
  // }

  // The key should be UID for Message keys???
  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving member $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'pidFrom': pidFrom,
      'pidTo': pidTo,
      'messageType': messageType,
      'timestamp': timestamp,
      'data': data,
      'responseCode': responseCode,
      'description': description,
      'comment': comment,
    };
  }
}