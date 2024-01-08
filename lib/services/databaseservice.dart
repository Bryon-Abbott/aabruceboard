import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Todo: Convert this to a Database Factory
class DatabaseService {
  // Todo: Relook at why uid is required to simplefy.
  String? uid; // Current Active User ID - This parameter never needs to be used ... as it is looked up.
  String? toUid; // Second User ID for Messages
  String? fromUid; // Second User ID for Messages

  String? sidKey; // Series ID
  String? gidKey; // Game ID (User as Game ID and Board ID)
  String? cidKey; // Player ID (Used as Member)

  String messageLocation; // Where to write / read messages (default to
  FSDocType fsDocType;

  FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference configCollection = FirebaseFirestore.instance
      .collection('Config');

  final CollectionReference playerCollection = FirebaseFirestore.instance
      .collection('Player');

  late CollectionReference docCollection;
  late DocumentReference statsDocument;
  late DocumentReference nextIdDocument;

  DatabaseService(this.fsDocType,
      { this.toUid, this.fromUid, this.uid,
        this.cidKey, this.sidKey, this.gidKey,
        this.messageLocation = 'Incoming',
      }) {
    // If UID not passed in, try to calculate it from Firebase Auth.
    // In fact you should never need to pass in UID as long as you check
    // to ensure the user is signed in.
    log('Database: DatabaseService: Player Collection ${playerCollection.path}');

    if (uid == null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) uid = user.uid;
    }
    if ( uid == null ) {
      log("Database: DatabaseService: Didn't get UID!!!");
    }
    // if toUid not set ... set it to the current users uid.
    toUid ??= uid;
    // if toUid not set ... set it to the current users uid.
    fromUid ??= uid;

    log('Database: DatabaseService: Class Type is > $fsDocType');
    switch (fsDocType) {
      case FSDocType.messageowner: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);  // Write stats to sending player?
        docCollection = playerCollection.doc(toUid).collection('MessageOwner');
        //.doc(uid).collection('Incoming');
        log('Database: Found "MessageOwner" class');
        log(docCollection.path);
      }
      break;
      case FSDocType.message: {
        nextIdDocument = playerCollection.doc(uid);  // Next number in sender Player id
        statsDocument = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid);
        docCollection = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid).collection(messageLocation);
        log('Database: DatabaseService: Found "Message" class : ${docCollection.path}');
        log(docCollection.path);
      }
      break;
      case FSDocType.player: {
        nextIdDocument = configCollection.doc('Production');
        statsDocument = configCollection.doc('Production');
        docCollection = playerCollection;
        log('Database: DatabaseService: Found "Player" class');
      }
      break;
      case FSDocType.series: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Series');
        log('Database: DatabaseService: Found "Series" class');
      }
      break;
      case FSDocType.access: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Access');
        log('Database: DatabaseService: Found "Access" class');
      }
      break;
      case FSDocType.game: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Game');
        log('Database: DatabaseService: Found "Game" class');
      }
      break;
      case FSDocType.board: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series')
            .doc(sidKey).collection('Game')
            .doc(gidKey);
        docCollection = playerCollection.doc(uid).collection('Series')
            .doc(sidKey).collection('Game')
            .doc(gidKey).collection('Board');
        log('Database: DatabaseService: Found "Board" class');
      }
      break;
      case FSDocType.membership: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Membership');
        log('Database: DatabaseService: Found "Membership" class : ${docCollection.path}');
        log(docCollection.path);
      }
      break;
      case FSDocType.community: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Community');
        log('Database: DatabaseService: Found "Membership" class');
      }
      break;
      case FSDocType.member: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Community').doc(cidKey);
        docCollection = playerCollection.doc(uid).collection('Community').doc(cidKey).collection('Member');
        log('Database: DatabaseService: Found "Member" class');
        log(docCollection.path);
      }
      break;
      default: {
        log('Database: MessageSerive: Undefined class $fsDocType');
      }
      break;
    }
    log('Database: DatabaseService:Setting up DatabaseService $uid');
  }

// =============================================================================
//                ***   FirestoreDoc DATABASE MEMBERS   ***
// =============================================================================
  Future<void> fsDocAdd(FirestoreDoc fsDoc) async {
    int noDocs = -1;
    // If there is already a docId, use it vs getting the Next Number
    log("Database: fsDocAdd: adding documnet : ${fsDoc.docId}");
    if (fsDoc.docId == -1) {
      // Get the next FirestoreDoc number for the player
      log('Database: fsDocAdd: creating new key');
      log(nextIdDocument.path);
      await nextIdDocument.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        fsDoc.docId = data[fsDoc.nextIdField] ?? 0;  // If nextSid not found, start at 0.
      },
          onError: (e) {
            log("Error getting Player Next Series ID: $e");
            fsDoc.docId = 9999;
          }
      );
      // log('Message: fsDocAdd: fsDoc Typs: ${fsDoc.runtimeType} fsDocId: ${fsDoc.docId} ');
      // Set or Increment the next Series number
      if ( fsDoc.docId == 0 ) {
        await nextIdDocument.update( {fsDoc.nextIdField: 1}, );
      } else {
        await nextIdDocument.update( {fsDoc.nextIdField: FieldValue.increment(1)}, );
      }
    }
    // log('Updating Firebase ${fsDoc.updateMap}');
    log('Database: fsDocAdd: Adding document ${fsDoc.runtimeType} Key: ${fsDoc.key}');
    log(docCollection.path);
    await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    if (fsDoc.totalField != 'NO-TOTALS') {
      log('Database: fsDocAdd: updating number of docs $noDocs');
      log(statsDocument.path);
      await statsDocument.update({ fsDoc.totalField: noDocs} );
      log('Database: fsDocAdd: updated number of docs $noDocs');
    }
  }
  // Update the FirestoreDoc with data in provided Series class.
  Future<void> fsDocUpdate(FirestoreDoc fsDoc) async {
    return await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> fsDocDelete(FirestoreDoc fsDoc) async {
    int noDocs = -1;
    log('Database: fsDocDelete: path: ${docCollection.path} key: ${fsDoc.key} ');
    log(docCollection.path);
    await docCollection.doc(fsDoc.key).delete();
    // fsDoc = FirestoreDoc(data: {});  // Clear out the class?

    if (fsDoc.totalField != 'NO-TOTALS') {
      await docCollection.count().get()
          .then((res) => noDocs = res.count,
      );
      await statsDocument.update({ fsDoc.totalField: noDocs} );
    }
  }

  // Series list from snapshot
  List<FirestoreDoc> _fsDocListFromSnapshot(QuerySnapshot snapshot) {
    // log('Collection Size is ${snapshot.size} UID: $uid');
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
      return fsDoc;
    }).toList();
  }

  // Get data from snapshots
  FirestoreDoc _fsDocFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    log('Database: fsDocFromSnapshot: $data ... $fsDocType');
    return FirestoreDoc( fsDocType, data: data );
  }

  // get FirestoreDoc stream
  Stream<FirestoreDoc> fsDocStream({String? key, int? docId}) {
    log('Database fsDocStream: getting player for U: $key Path: ${playerCollection.path}');
    log('Database fsDocStream: Parent: ${docCollection.toString()} ');
    Stream<FirestoreDoc> fsDocStream;
    if (key != null) {
      fsDocStream = docCollection.doc(key).snapshots()
          .map((DocumentSnapshot doc) => _fsDocFromSnapshot(doc));
//    .map(_playerFromSnapshot);
    } else if (docId != null) {
      // Note ... only 1 document matches the docId so select the firts ..
      fsDocStream = docCollection.where('docId', isEqualTo:docId ).snapshots()
          .map((QuerySnapshot doc) => _fsDocFromSnapshot(doc.docs.first));
    } else {
      fsDocStream = const Stream.empty();
    }
    return fsDocStream;
  }

//  Future<FirestoreDoc?> fsDoc({required String key}) async {
  Future<FirestoreDoc?> fsDoc({String? key, int? docId}) async {
    log('Database: fsDoc: getting key ($key), docId is ($docId)');
    log(docCollection.path);
    FirestoreDoc? fsDoc;
    if (key != null ) {
      log('database: fsDoc: Getting doc by key: $key');
      await docCollection.doc(key).get()
        .then((DocumentSnapshot doc) {
          log('database: fsDoc: doc collection from key exists: ${doc.exists}');
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            fsDoc = FirestoreDoc(fsDocType, data: data);
          } else {
            fsDoc = null;
          }
        },
        onError: (error) {
          log("Error getting Player UID: $uid, Error: $error");
          fsDoc = null;
        });
    } else if (docId != null ) {
      log('database: fsDoc: Getting doc by docId: $docId');
      await docCollection.where('docId', isEqualTo:docId ).get()
          .then((querySnapshot) {
        log('database: fsDoc: doc collection from docId size: ${querySnapshot.size}');
        if (querySnapshot.size > 0) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          fsDoc = FirestoreDoc(fsDocType, data: data);
          log('Got Document by ID : ${fsDoc!.docId}');
        } else {
          fsDoc = null;
          log('No Document by ID : $docId');
        }
      },
          onError: (error) {
            log("Error getting Player UID: $uid, Error: $error");
            fsDoc = null;
          });
    } else {
      log('Database: fsDoc: Error: Missing key?');
      fsDoc = null;
    }
    return fsDoc;
  }

  //get FirestoreDoc List stream
  Stream<List<FirestoreDoc>> get fsDocListStream {
    log('Database: fsDocListStream: ');
    log(docCollection.path);
    Stream<QuerySnapshot<Object?>> s001 = docCollection.snapshots();
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
    // return docCollection.snapshots()
    //   .map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
//        .map(_fsDocListFromSnapshot);
  }

  //get FirestoreDoc List stream
  Stream<List<FirestoreDoc>> fsDocGroupListStream({ required int pid, required int cid} ) {
    log('Database: fsDocGroupListStream: pid: ${pid} cid: ${cid} ');
    Stream<QuerySnapshot<Object?>> s001 =
      db.collectionGroup("Access")
        .where('pid', isEqualTo: pid)
        .where('cid', isEqualTo: cid)
        .snapshots();
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
  }
  //get FirestoreDoc List
  //Future<List<FirestoreDoc>> get fsDocList async {
  Future<List<FirestoreDoc>> get fsDocList async {
    log('Database: fsDocList: ');
    log(docCollection.path);
    List<FirestoreDoc> fsDocList = [];
    await docCollection.get().then((snapshot) {
      log('Database: fsDocList: Snapshot Size ${snapshot.size}');
      for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        log('Database: fsDocList: Snapshot Doc ID:  ${doc.id}');
        Map<String, dynamic> data =  doc.data()! as Map<String, dynamic>;
        FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
        fsDocList.add(fsDoc);
      }
       // snapshot.docs.forEach((doc) {
       // });
       log('database: fsDocList: return type ${fsDocList.runtimeType} Length: ${fsDocList.length}');
      },
      onError: (e) => log("Error getting document: $e"),
    );
    return fsDocList;
  }

  //get FirestoreDoc List stream
  // ToDo: Fix this.
  Future<int> get fsDocCount async {
    int docCount=0;
    log('Database: fsDocCount: ');
    log(docCollection.path);

    await docCollection.count().get().then((snapshot) {
      docCount = snapshot.count;
    });
    return Future<int>.value(docCount);
  }
}