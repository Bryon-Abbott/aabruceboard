import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  aaUser? _userFromFirebaseUser(User? user) {
    return user != null ? aaUser(uid: user.uid) : null;
  }

  String get displayName {
    if (_auth.currentUser == null) {
      return "No User Signed On";
    } else {
      return _auth.currentUser?.displayName ?? "No Display Name";
    }
  }

  Future<void> updateDisplayName(String newDisplayName) async {
    if (_auth.currentUser != null) {
      return await _auth.currentUser?.updateDisplayName(newDisplayName);
    }
  }

  // auth change user stream
  Stream<aaUser?> get user {
    return _auth.authStateChanges()
      .map((User? user) => _userFromFirebaseUser(user));
      //.map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user!;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    } 
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user!.updateDisplayName('Display Name');
      User user = result.user!;
      // create a new document for the user with the uid
      await DatabaseService(uid: user.uid).updatePlayer('FNAME', 'LNAME', "FL");
      return _userFromFirebaseUser(user);
    } catch (error) {
      print(error.toString());
      return null;
    } 
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

}