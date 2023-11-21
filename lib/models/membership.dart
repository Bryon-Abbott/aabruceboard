import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Membership implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextMsid';
  @override
  final String totalField = 'noMemberships';
  @override
  final NumberFormat _keyFormat = NumberFormat("MS0000", "en_US");
  // Data Class Variables
  int cid;
  int pid;
  String uid;
  String status;

  //Membership({ required this.cid, required this.pid, required this.status, });
  Membership({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        cid = data['cid'] ?? -1,
        pid = data['pid'] ?? -1,
        uid = data['uid'] ?? 'error',
        status = data['status'] ?? 'error';

  @override
  String get key {
    // Format Key for Document ID
    NumberFormat cFormat = NumberFormat("C0000", "en_US");
    String cKey = cFormat.format(cid);
    NumberFormat pFormat = NumberFormat("P00000000", "en_US");
    String pKey = pFormat.format(pid);
    log("Retrieving community $pKey$cKey");
    return "$pKey$cKey";
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    cid = data['cid'] ?? -1;
    pid = data['pid'] ?? -1;
    uid = data['uid'] ?? 'error';
    status = data['status'] ?? 'error';
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'cid': cid,
      'pid': pid,
      'uid': uid,
      'status': status,
    };
  }
}