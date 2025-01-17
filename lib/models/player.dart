import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/authservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const int kExcludePlayerNo = 1000;

enum PlayerLevel implements Comparable<PlayerLevel> {
  levelUndefined(level: 0, desc: "Undefined Subscription"),
  levelBasic(level: 100, desc: "Basic Subscription"),
  levelPro(level: 200 , desc: "Pro Subscription"),
  levelElite(level: 300 , desc: "Elite Subscription"),
  ;

  const PlayerLevel({required this.level, required this.desc});
  final int level;
  final String desc;

  @override
  int compareTo(PlayerLevel other) => level - other.level;

  static String levelDescription(int level) {
    for (PlayerLevel p in PlayerLevel.values) {
      if (p.level == level) {
        return p.desc;
      }
    }
    return "Undefined Code";
  }
  static PlayerLevel getPlayerLevel(int level ) {
    for (PlayerLevel p in PlayerLevel.values) {
      if (p.level == level) {
        return p;
      }
    }
    return PlayerLevel.levelUndefined;
  }

}

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
  String get email {
    return _auth.email;
  }
  bool get emailVerified {
    return _auth.emailVerified;
  }

  void sendEmailVerification() {
    _auth.currentUser?.sendEmailVerification();
  }

  void sendPasswordResetEmail(email){
    _auth.sendPasswordResetEmail(email);
  }

  void signOut() {
    _auth.signOut();
  }

  bool deleteUserAccount()  {
    try {
      _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      log("${e.code}, ${e.message}", name: '${runtimeType.toString()}:deleteUserAccount()');
      if (e.code == "requires-recent-login") {
        return false;
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      log("$e");
      // Handle general exception
    }
    return true;
  }

  // Future<void> _reauthenticateAndDelete() async {
  //   log("Reauthenticating ... ", name: '${runtimeType.toString()}:_reauthenticateAndDelete()');
  //   try {
  //     final providerData = _auth.currentUser?.providerData.first;
  //     if (AppleAuthProvider().providerId == providerData!.providerId) {
  //       await _auth.currentUser!
  //           .reauthenticateWithProvider(AppleAuthProvider());
  //     } else if (GoogleAuthProvider().providerId == providerData.providerId) {
  //       await _auth.currentUser!
  //           .reauthenticateWithProvider(GoogleAuthProvider());
  //     }
  //
  //     await _auth.currentUser?.delete();
  //   } catch (e) {
  //     log("Unhandled Error ... ", name: '${runtimeType.toString()}:_reauthenticateAndDelete()');
  //     // Handle exceptions
  //   }
  // }
}

class Player implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextPid';
  @override
  final String totalField = 'noPlayers';

  static final NumberFormat _keyFormat = NumberFormat("P00000000", "en_US");
  // Data Class Variables
  String uid;
  String fName;
  String lName;
  String initials;
  int pid;
  int level;
  int status;  // 0 = Deleted, 1 = Active,

  // Totals
  int noMemberships = 0;
  int noCommunities = 0;
  int noCommunityMembers = 0;
  int noSeries = 0;
  int noMessages = 0;
  int noTotalGames = 0;

  // Auto Approval Settings
  bool autoProcessReq = false;
  bool autoProcessNot = false;
  bool autoProcessAck = false;
  bool autoProcessAcc = false;

  Player({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        uid = data['uid'] ?? 'Anonymous',
        pid = data['pid'] ?? -1,
        fName = data['fName'] ?? 'Fname',
        lName = data['lName'] ?? 'Lname',
        initials = data['initials'] ?? 'FL',
        level = data['level'] ?? 100,
        status = data['status'] ?? 1,  // If not found, assume active?
        autoProcessReq = data['autoProcessReq'] ?? false,
        autoProcessNot = data['autoProcessNot'] ?? false,
        autoProcessAck = data['autoProcessAck'] ?? false,
        autoProcessAcc = data['autoProcessAcc'] ?? false,
        noMemberships = data['noMemberships'] ?? 0,
        noCommunities = data['noCommunities'] ?? 0,
        noSeries = data['noSeries'] ?? 0,
        noMessages = data['noMessages'] ?? 0;

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
    docId = data['docId'] ?? docId;
    uid = data['uid'] ?? uid;
    pid = data['pid'] ?? pid;
    fName = data['fName'] ?? fName;
    lName = data['lName'] ?? lName;
    initials = data['initials'] ?? initials;
    level = data['level'] ?? level;
    status = data['status'] ?? status;
    autoProcessReq = data['autoProcessReq'] ?? autoProcessReq;
    autoProcessNot = data['autoProcessNot'] ?? autoProcessNot;
    autoProcessAck = data['autoProcessAck'] ?? autoProcessAck;
    autoProcessAcc = data['autoProcessAcc'] ?? autoProcessAcc;
    noMemberships = data['noMemberships'] ?? noMemberships;
    noCommunities = data['noCommunities'] ?? noCommunities;
    noSeries = data['noSeries'] ?? noSeries;
    noMessages = data['noMessages'] ?? noMessages;
  }

  // Returns a Map<String, dynamic> of all member variables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'uid': uid,
      'pid': pid,
      'fName': fName,
      'lName': lName,
      'initials': initials,
      'level': level,
      'status': status,
      'autoProcessReq': autoProcessReq,  // Server Side - Not Required here?
      'autoProcessNot': autoProcessNot,
      'autoProcessAck': autoProcessAck,
      'autoProcessAcc': autoProcessAcc,
    };
  }
}

