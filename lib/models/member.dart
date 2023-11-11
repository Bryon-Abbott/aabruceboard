// Community Member
import 'dart:developer';

import 'package:intl/intl.dart';

class Member {
  int mid;
  String uid;  // /Player/{PID}/Community/{CID}/Member/{PID} Note: PID = MID
  int credits;

  //Member({ required this.cid, required this.uid, required this.credits, });
  Member({ required Map<String, dynamic> data, }) :
        mid = data['mid'] ?? -1,
        uid = data['uid'] ?? 'error',
        credits = data['credits'] ?? 0;

  void update({ required Map<String, dynamic> data, }) {
    mid = data['mid'] ?? mid;
    uid = data['uid'] ?? uid;
    credits = data['credits'] ?? credits;
  }

  String get key {
    // Format Key for Document ID
    NumberFormat intFormat = NumberFormat("M0000", "en_US");
    String key = intFormat.format(mid);
    log("Retrieving member $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  Map<String, dynamic> get updateMap {
    return {
      'mid': mid,
      'uid': uid,
      'credits': credits,
    };
  }
}