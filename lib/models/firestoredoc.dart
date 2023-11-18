// Firestore Document - BaseClass
import 'dart:developer';

import 'package:intl/intl.dart';

class FirestoreDoc {
  final String nextIdField = 'nextFsid';    // Stored in Player
  final String totalField = 'noDocuments';  // Strored in Parent
  int docId = -1;
  final NumberFormat _keyFormat = NumberFormat("FS00000000", "en_US");

  FirestoreDoc( { required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1;

  void update({ required Map<String, dynamic> data, }) {
    docId = data['fsid'] ?? docId;  // From Super
  }

  String get key
  { // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving member $key");
    return key;
  }

  Map<String, dynamic> get updateMap {
    return { 'docId': docId, };
  }
}