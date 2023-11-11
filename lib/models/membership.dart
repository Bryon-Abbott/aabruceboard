import 'dart:developer';

import 'package:intl/intl.dart';

class Membership {
  int cid;
  int pid;
  String uid;
  String status;

  //Membership({ required this.cid, required this.pid, required this.status, });
  Membership({ required Map<String, dynamic> data, }) :
        cid = data['cid'] ?? -1,
        pid = data['pid'] ?? -1,
        uid = data['uid'] ?? 'error',
        status = data['status'] ?? 'error';

  String get key {
    // Format Key for Document ID
    NumberFormat cFormat = NumberFormat("C0000", "en_US");
    String cKey = cFormat.format(cid);
    NumberFormat pFormat = NumberFormat("P00000000", "en_US");
    String pKey = pFormat.format(pid);
    log("Retrieving community $pKey$cKey");
    return "$pKey$cKey";
  }

  // Returns a Map<String, dynamic> of all member veriables.
  Map<String, dynamic> get updateMap {
    return {
      'cid': cid,
      'pid': pid,
      'uid': uid,
      'status': status,
    };
  }
}