import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:intl/intl.dart';

class BruceUser {

  final AuthService _auth = AuthService();
  final String uid;

  BruceUser({ this.uid = 'Anonymous'});

  // Note: displayName is stored in the Firestore Auth system not in
  // the Firebase database.  This is similar to email and phone number.
  // This is only accessible by the actual user.
  String get displayName {
    return _auth.displayName;
  }
}

class Player implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextPid';
  @override
  final String totalField = 'noPlayers';
  @override
  static final NumberFormat _keyFormat = NumberFormat("P00000000", "en_US");
  // Data Class Variables
  String uid;
  String fName;
  String lName;
  String initials;
  int pid;

  // Totalizers
  int noMemberships = 0;
  int noCommunities = 0;
  int noCommunityMembers = 0;
  int noSeries = 0;
  int noTotalGames = 0;

  // Player({required this.uid, required this.pid,
  //   required this.fName, required this.lName, required this.initials,
  // });
  Player({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        uid = data['uid'] ?? 'Anonymous',
        pid = data['pid'] ?? -1,
        fName = data['fName'] ?? 'Fname',
        lName = data['lName'] ?? 'Lname',
        initials = data['initials'] ?? 'FL',
        noMemberships = data['noMemberships'] ?? 0,
        noCommunities = data['noCommunities'] ?? 0,
        noSeries = data['noSeries'] ?? 0
  {
    log('Creating player ID: $docId  U: $uid fName: $fName', name: '${runtimeType.toString()}:Player()');
  }

  // The key for the Player Document is the Firestore Users ID (uid)
  @override
  String get key {
    return uid;
  }
  // The key created from PID used for composite keys (Memberships)
  static String Key(int pid) {
    String Key = _keyFormat.format(pid);
    return Key;
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? -1;
    uid = data['uid'] ?? 'Anonymous';
    pid = data['pid'] ?? -1;
    fName = data['fName'] ?? 'Fname';
    lName = data['lName'] ?? 'Lname';
    initials = data['initials'] ?? 'FL';
    noMemberships = data['noMemberships'] ?? 0;
    noCommunities = data['noCommunities'] ?? 0;
    noSeries = data['noSeries'] ?? 0;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'uid': uid,
      'pid': pid,
      'fName': fName,
      'lName': lName,
      'initials': initials,
    };
  }
}