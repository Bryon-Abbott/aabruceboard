import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum AuditCode implements Comparable<AuditCode> {
  memberAdded(code: 100, desc: "Member added to Community"),
  memberRemoved(code: 101 , desc: "Member removed from Community"),
  squareRequested(code: 200, desc: "Square Requested by Player"),
  squareAssignedPlayer(code: 201, desc: "Square Assigned by Owner"),
  squareAssignedExclude(code: 202, desc: "Square Excluded by Owner"),
  squareAssignedCloud(code: 203, desc: "Square Assigned by Cloud"),
  squareFilledPlayer(code: 204, desc: "Square Player Filled by Owner"),
  squareFilledExclude(code: 205, desc: "Square Exclude Filled by Owner"),
  squareRejectedPlayer(code: 206, desc: "Square Request Rejected by Owner"),
  memberCreditsUpdated(code: 300, desc: "Member Credits Update by Owner"),
  memberCreditsRequested(code: 301, desc: "Member Credits update by Player request"),
  memberCreditsDistributed(code: 302, desc: "Member Credits updated by Distribution"),
  communityCreditsDistributed(code: 303, desc: "Community Credits updated by Distribution"),
  ;

  const AuditCode({required this.code, required this.desc});
  final int code;
  final String desc;

  @override
  int compareTo(AuditCode other) => code - other.code;

  static String auditDescription(int code) {
    for (AuditCode a in AuditCode.values) {
      if (a.code == code) {
        return a.desc;
      }
    }
    return "Undefined Code";
  }
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
  int square;
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
    square = data['square'] ?? -1,
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
    square = data['square'] ?? square;
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
      'square': square, 
      'debit': debit,
      'credit': credit,
    };
  }
}