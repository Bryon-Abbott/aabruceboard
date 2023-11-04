import 'package:bruceboard/services/auth.dart';

class BruceUser {

  final AuthService _auth = AuthService();
  final String uid;

  BruceUser({ required this.uid });

  // Note: displayName is stored in the Firestore Auth system not in
  // the Firebase database.  This is similar to email and phone number.
  // This is only accessible by the actual user.
  String get displayName {
    return _auth.displayName;
  }
}

class Player {

  final String uid;
  final String fName;
  final String lName;
  final String initials;
  final int pid;

  // Next Numebrs
  int nextSid = 0; // Players series start at 0 (0-9999)
  int nextGid = 0; // Players gaems start at 0 (0-999999)
  int nextCid = 0; // Players communities start at 0 (0-99999)
  int nextMid = 0; // Players membership start at 0 (0-9999)


  int noMemberships = 0;
  int noCommunities = 0;
  int noCommunityMembers = 0;
  int noSeries = 0;
  int noTotalGames = 0;

  Player({required this.uid, required this.pid,
    required this.fName, required this.lName, required this.initials,
  });

}