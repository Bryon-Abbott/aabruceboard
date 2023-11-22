// Community Member
import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Member implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextMid';
  @override
  final String totalField = 'noMembers';
  @override
  final NumberFormat _keyFormat = NumberFormat("M0000", "en_US");
  // Data Class Variables
 // int mid;
  String uid;  // /Player/{PID}/Community/{CID}/Member/{PID} Note: PID = MID
  int credits;

  //Member({ required this.cid, required this.uid, required this.credits, });
  @override
  Member({ required Map<String, dynamic> data, }) :
    docId = data['docId'] ?? -1,
//    mid = data['mid'] ?? -1,
    uid = data['uid'] ?? 'error',
    credits = data['credits'] ?? 0;

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
//    mid = data['mid'] ?? mid;
    uid = data['uid'] ?? uid;
    credits = data['credits'] ?? credits;
  }

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
//      'mid': mid,
      'uid': uid,
      'credits': credits,
    };
  }
}