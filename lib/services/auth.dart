import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  BruceUser? _userFromFirebaseUser(User? user) {
    return user != null ? BruceUser(uid: user.uid) : null;
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
  Stream<BruceUser?> get user {
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
 //     Player player = Player(data: {'uid': user.uid, 'pid': -1, 'fName': 'FNAME', 'lName': 'LNAME', 'initials': 'FL'} );
        Player player = Player(data: { 'uid': user.uid } );
        log('Adding new player ... U:${player.uid}, P:${player.pid}, fName: ${player.fName} ');
      // Todo: Look to see if this can use the fsDoc database class
//      await DatabaseService(FSDocType.player, uid: user.uid).updatePlayer(player);
      await DatabaseService(FSDocType.player, uid: user.uid).fsDocAdd(player);
      player.pid = player.docId; // Make the PID equal to the docID and save to DB
      await DatabaseService(FSDocType.player, uid: user.uid).fsDocUpdate(player);
      //await DatabaseService(player, uid: user.uid).fsDocUpdate();
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