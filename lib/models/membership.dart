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
  final NumberFormat _keyFormat = NumberFormat("C0000", "en_US");
  // Data Class Variables
  int cid;  // Community ID
  int cpid;  // Community PID
  int pid;  // Community PID
//  String uid;
  String status;

  static final NumberFormat _cFormat = NumberFormat("C0000", "en_US");
  static final NumberFormat _pFormat = NumberFormat("P00000000", "en_US");

  //Membership({ required this.cid, required this.pid, required this.status, });
  Membership({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        cid = data['cid'] ?? -1,
        cpid = data['cpid'] ?? -1,
        pid = data['pid'] ?? -1,
        status = data['status'] ?? 'error';

  @override
  static String KEY(int cpid, int cid) {
    // Format Key for Document ID
    String cKey = _cFormat.format(cid);
    String pKey = _pFormat.format(cpid);
    log("Retrieving community $pKey$cKey", name: 'Membership:KEY:...');
    return "$pKey$cKey";
  }

  @override
  String get key {
    // Format Key for Document ID
    NumberFormat cFormat = NumberFormat("C0000", "en_US");
    String cKey = cFormat.format(cid);
    NumberFormat pFormat = NumberFormat("P00000000", "en_US");
    String pKey = pFormat.format(cpid);
    log("Membership: key: Retrieving community $pKey$cKey", name: '${runtimeType.toString()}:...');
    return "$pKey$cKey";
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    cid = data['cid'] ?? cid;
    cpid = data['cpid'] ?? cpid;
    pid = data['pid'] ?? pid;
    status = data['status'] ?? status;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'cid': cid,
      'cpid': cpid,
      'pid': pid,
      'status': status,
    };
  }
}