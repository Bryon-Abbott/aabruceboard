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

// Note: pid == uid
class Player {

  final String uid;
  final String fName;
  final String lName;
  final String initials;

  int noCommunityMembers = 0;
  int noSeries = 0;
  int noTotalGames = 0;

  Player({required this.uid, required this.fName, required this.lName, required this.initials});

}