//import 'package:aaflutterfirebase/models/brew.dart';
import 'dart:developer';

import 'package:bruceboard/models/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // collection reference
  final CollectionReference playerCollection = FirebaseFirestore.instance.collection('Players');

  Future<void> updatePlayer(String fName, String lName, String initials) async {
    return await playerCollection.doc(uid).set({
      'fName': fName,
      'lName': lName,
      'initials': initials,
    });
  }

  // brew list from snapshot
  List<Player> _playerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Player(
        uid: uid,
        fName: data['fName'] ?? 'FNAME',
        lName: data['lName'] ?? 'LNAME',
        initials: data['initials'] ?? 'FN',
        // name: data['name'] ?? '',
        // strength: data['strength'] ?? 0,
        // sugars: data['sugars'] ?? '0'
          // name: doc.data['name'] ?? '',
          // strength: doc.data['strength'] ?? 0,
          // sugars: doc.data['sugars'] ?? '0'
      );
    }).toList();
  }

  // Player data from snapshots
  Player _playerFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    // log('Getting Player from Snapshot ${data['fName']} ${data['lName']} ${data['initials']}');
    return Player(
      uid: uid,
      fName: data['fName'],
      lName: data['lName'],
      initials: data['initials']
      // name: snapshot.data['name'],
      // sugars: snapshot!.data['sugars'],
      // strength: snapshot!.data['strength']
    );
  }

  //get players stream
  Stream<List<Player>> get players {
    return playerCollection.snapshots()
      .map(_playerListFromSnapshot);
  }

  // get user doc stream
  Stream<Player> get player {
    // log('Getting Player $uid');
    return playerCollection.doc(uid).snapshots()
    .map((DocumentSnapshot doc) => _playerFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }

}