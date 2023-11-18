import 'dart:developer';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/membership.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Todo: Convert this to a Database Factory
class MessageService {
  // Todo: Relook at why uid is required to simplefy.
  String? uid; // Current Active User ID
  String? sidKey; // Series ID
  String? gidKey; // Game ID (User as Game ID and Board ID)
  String? cidKey; // Player ID (Used as Member)
  FirestoreDoc fsDoc;

//  FirebaseFirestore db;
  final CollectionReference configCollection = FirebaseFirestore.instance
      .collection('Config');

  final CollectionReference playerCollection = FirebaseFirestore.instance
      .collection('Player');

  // late CollectionReference seriesCollection;
  // late CollectionReference communityCollection;
  // late CollectionReference membershipCollection;
  // late CollectionReference memberCollection;
  // late CollectionReference gameCollection;
  // late CollectionReference boardCollection;
  // late CollectionReference messageCollection;

  late CollectionReference docCollection;
  late CollectionReference parentCollection;

  MessageService(this.fsDoc, { this.uid, this.cidKey, this.sidKey, this.gidKey }) {
    // If UID not passed in, try to calculate it from Firebase Auth.
    // In fact you should never need to pass in UID as long as you check
    // to ensure the user is signed in.
    if (uid == null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) uid = user.uid;
    }
    log('MessageService: Class Type is > ${fsDoc.runtimeType}');
    switch (fsDoc.runtimeType.toString()) {
      case 'Message': {
        parentCollection = playerCollection;
        docCollection = playerCollection.doc(uid).collection('Message');
        log('MessageSerive: Found "Message" class');
      }
      break;
      default: {
        log('MessageSerive: Undefined class ${fsDoc.runtimeType}');
      }
      break;
    }

    //log('Setting up DatabaseService ${uid}');
    // if (uid != null) {
    //   seriesCollection = playerCollection.doc(uid).collection(
    //       'Series'); // List of Series of Games User manages
    //   communityCollection = playerCollection.doc(uid).collection(
    //       'Community'); // List of Community of Players User manages
    //   membershipCollection = playerCollection.doc(uid).collection(
    //       'Membership'); // List of Communities the User has joined
    //   messageCollection = playerCollection.doc(uid).collection(
    //       'Membership'); // List of Communities the User has joined
    //   // If uid found ... create the remaining
    //   if (cidKey != null) {
    //     memberCollection = communityCollection.doc(cidKey).collection('Member'); // List of Members in a Community
    //   }
    //   if (sidKey != null) {
    //     gameCollection = seriesCollection.doc(sidKey).collection('Game'); // List of Games in a Series
    //   }
    //   if (gidKey != null) {
    //     boardCollection = gameCollection.doc(gidKey).collection('Board'); // Board associated with a Game (GID=BID)
    //   }
    // }
  }
// =============================================================================
//                ***   DATABASE MEMBERS   ***
// =============================================================================
  Future<void> fsDocAdd() async {
    int noDocs = -1;
    // Get the next series number for the player
    await playerCollection.doc(uid).get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        fsDoc.docId = data[fsDoc.nextIdField] ?? 0;  // If nextSid not found, start at 0.
      },
        onError: (e) {
          log("Error getting Player Next Series ID: $e");
          fsDoc.docId = 9999;
        }
    );
    log('Message: fsDocAdd: fsDoc Typs: ${fsDoc.runtimeType} fsDocId: ${fsDoc.docId} ');
    // Set or Increment the next Series number
    if (fsDoc.docId == 0 ) {
      await playerCollection.doc(uid).update(
        {fsDoc.nextIdField: 1},
      );
    } else {
      await playerCollection.doc(uid).update(
        {fsDoc.nextIdField: FieldValue.increment(1)},
      );
    }

    // await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
    await docCollection.doc(uid).set(fsDoc.updateMap);
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    await parentCollection.doc(uid).update({
      "noMessages": noDocs}  // ToDo: Fix this>
    );
  }
  // Update the series Doc with data in provided Series class.
  Future<void> fsDocUpdate() async {
    return await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> fsDocDelete(String docKey) async {
    int noDocs = -1;

    await docCollection.doc(docKey).delete();
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    await parentCollection.doc(uid).update({
      "noMessages": noDocs}
    );
  }

  // Series list from snapshot
  List<FirestoreDoc> _fsDocListFromSnapshot(QuerySnapshot snapshot) {
    //seriesCollection = playerCollection.doc(uid).collection('Series');
    log('Series Size is ${snapshot.size} UID: $uid');
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      FirestoreDoc fsDoc = FirestoreDoc( data: data );
      return fsDoc;
    }).toList();
  }

  // Get Series data from snapshots
  Series _fsDocFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Series( data: data );
  }

  //get collections stream
  Stream<List<FirestoreDoc>> get fsDocList {
    return docCollection.snapshots()
        .map(_fsDocListFromSnapshot);
  }
}