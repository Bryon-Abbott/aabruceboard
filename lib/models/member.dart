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
  static final NumberFormat _keyFormat = NumberFormat("P00000000", "en_US");
  // Data Class Variables
  int credits;

  //Member({ required this.cid, required this.uid, required this.credits, });
  @override
  Member({ required Map<String, dynamic> data, }) :
    docId = data['docId'] ?? -1,  // Member's docId == PID
    credits = data['credits'] ?? 0;

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    credits = data['credits'] ?? credits;
  }

  @override
  static String KEY(int cid) {
    String key = _keyFormat.format(cid);
    return key;
  }

  static String Key(int cid) {
    String key = _keyFormat.format(cid);
    return key;
  }

  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving member $key", name: '${runtimeType.toString()}:key');
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'credits': credits,
    };
  }
}