import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum AuditCode implements Comparable<AuditCode> {
  memberAdded(code:10, desc: "Member added to Community"),
  memberRemoved(code:20, desc: "Member removed from Community"),
  squareRequested(code: 30, desc: "Square Requested by Player"),
  squareAssigned(code: 40, desc: "Square Assigned by Owner"),
  squareFilled(code:50, desc: "Square Filled by Owner"),
  squareCloudAssigned(code:60, desc: "Square Assigned by Cloud"),
  memberCreditsUpdated(code:70, desc: "Member Credits Update by Owner"),
  memberCreditsRequested(code: 80, desc: "Member Credits update by Player request"),
  memberCreditsDisttributed(code: 90, desc: "Member Credits updated by Distribution");

  const AuditCode({required this.code, required this.desc});
  final int code;
  final String desc;

  @override
  int compareTo(AuditCode other) => code - other.code;
}

class Audit implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextAuid';
  @override
  final String totalField = 'noAuditTrns';
  // @override
  Timestamp timestamp;
  int code;       //
  int playerPid;  // Transaction Player
  int ownerPid;   // Transaction Owner
  int cid;        // Community ID (Assums
  int sid;        // Series to which access is given.
  int gid;        // Game ID
  int debit;
  int credit;

  static final NumberFormat _keyFormat = NumberFormat("A00000000", "en_US");

  Audit({ required Map<String, dynamic> data, }) :
    docId = data['docId'] ?? -1,
    timestamp = data['timestamp'] ?? Timestamp.now(),
    playerPid = data['playerPid'] ?? -1,
    ownerPid = data['ownerPid'] ?? -1,
    code = data['code'] ?? -1,  // 20=Adjust Member Credit,
    sid = data['sid'] ?? -1,
    cid = data['cid'] ?? -1,
    gid = data['gid'] ?? -1,
    debit = data['debit'] ?? 0,
    credit = data['credit'] ?? 0
  ;

  // static String KEY(int cid) {
  //   String key = _keyFormat.format(cid);
  //   return key;
  // }
  //
  // static String Key(int cid) {
  //   String key = _keyFormat.format(cid);
  //   return key;
  // }

  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving Transaction $key", name: '${runtimeType.toString()}:key');
    return key;
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    timestamp = data['timestamp'] ?? timestamp;
    ownerPid = data['ownerPid'] ?? ownerPid;
    playerPid = data['playerPid'] ?? playerPid;
    code = data['code'] ?? code;
    sid = data['sid'] ?? sid;
    cid = data['cid'] ?? cid;
    gid = data['gi'] ?? gid;
    debit = data['debit'] ?? debit;
    credit = data['credit'] ?? credit;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'timestamp': timestamp,
      'ownerPid': ownerPid,
      'playerPid': playerPid,
      'code': code,
      'sid': sid,
      'cid': cid,
      'gid': gid,
      'debit': debit,
      'credit': credit,
    };
  }
}