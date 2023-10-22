import '../services/auth.dart';

class aaUser {

  final AuthService _auth = AuthService();
  final String uid;

  aaUser({ required this.uid });

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

  int noCommunityMembers = 0;
  int noCollections = 0;
  int noTotalGames = 0;

  Player({required this.uid, required this.fName, required this.lName, required this.initials});

}