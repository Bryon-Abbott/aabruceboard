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
    log('Database: DatabaseService: Player Collection ${playerCollection.path}', name: '${runtimeType.toString()}:...');

    if (uid == null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) uid = user.uid;
      else uid = 'Anonymous';
    }
    if ( uid == null ) {
      log("Database: DatabaseService: Didn't get UID!!!", name: '${runtimeType.toString()}:...');
    }
    // if toUid not set ... set it to the current users uid.
    toUid ??= uid;
    // if toUid not set ... set it to the current users uid.
    fromUid ??= uid;

    log('Database: DatabaseService: Class Type is > $fsDocType', name: '${runtimeType.toString()}:...');
    switch (fsDocType) {
      case FSDocType.messageowner: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);  // Write stats to sending player?
        docCollection = playerCollection.doc(toUid).collection('MessageOwner');
        //.doc(uid).collection('Incoming');
        log('Database: Found "MessageOwner" class', name: '${runtimeType.toString()}:...');
        log(docCollection.path, name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.message: {
        nextIdDocument = playerCollection.doc(uid);  // Next number in sender Player id
        statsDocument = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid);
        docCollection = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid).collection(messageLocation);
        log('Database: DatabaseService: Found "Message" class : ${docCollection.path}', name: '${runtimeType.toString()}:...');
        log(docCollection.path, name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.player: {
        nextIdDocument = configCollection.doc('Production');
        statsDocument = configCollection.doc('Production');
        docCollection = playerCollection;
        log('Database: DatabaseService: Found "Player" class', name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.series: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Series');
        log('Database: DatabaseService: Found "Series" class', name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.access: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Access');
        log('Database: DatabaseService: Found "Access" class', name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.game: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Game');
        log('Database: DatabaseService: Found "Game" class', name: '${runtimeType.toString()}:...');
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
        log('Database: DatabaseService: Found "Board" class', name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.membership: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Membership');
        log('Database: DatabaseService: Found "Membership" class : ${docCollection.path}', name: '${runtimeType.toString()}:...');
        log(docCollection.path, name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.community: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Community');
        log('Database: DatabaseService: Found "Membership" class', name: '${runtimeType.toString()}:...');
      }
      break;
      case FSDocType.member: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Community').doc(cidKey);
        docCollection = playerCollection.doc(uid).collection('Community').doc(cidKey).collection('Member');
        log('Database: DatabaseService: Found "Member" class', name: '${runtimeType.toString()}:...');
        log(docCollection.path, name: '${runtimeType.toString()}:...');
      }
      break;
      default: {
        log('Database: MessageSerive: Undefined class $fsDocType', name: '${runtimeType.toString()}:...');
      }
      break;
    }
    log('Database: DatabaseService:Setting up DatabaseService $uid', name: '${runtimeType.toString()}:...');
  }

// =============================================================================
//                ***   FirestoreDoc DATABASE MEMBERS   ***
// =============================================================================
  Future<void> fsDocAdd(FirestoreDoc fsDoc) async {
    int noDocs = -1;
    // If there is already a docId, use it vs getting the Next Number
    log("Database: fsDocAdd: adding documnet : ${fsDoc.docId}", name: '${runtimeType.toString()}:...');
    if (fsDoc.docId == -1) {
      // Get the next FirestoreDoc number for the player
      log('Database: fsDocAdd: creating new key', name: '${runtimeType.toString()}:...');
      log(nextIdDocument.path, name: '${runtimeType.toString()}:...');
      await nextIdDocument.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        fsDoc.docId = data[fsDoc.nextIdField] ?? 0;  // If nextSid not found, start at 0.
      },
          onError: (e) {
            log("Error getting Player Next Series ID: $e", name: '${runtimeType.toString()}:...');
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
    log('Database: fsDocAdd: Adding document ${fsDoc.runtimeType} Key: ${fsDoc.key}', name: '${runtimeType.toString()}:...');
    log(docCollection.path, name: '${runtimeType.toString()}:...');
    await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    if (fsDoc.totalField != 'NO-TOTALS') {
      log('fsDocAdd: updating number of docs $noDocs', name: '${runtimeType.toString()}:fsDocAdd()');
      log(statsDocument.path, name: '${runtimeType.toString()}:...');
      await statsDocument.update({ fsDoc.totalField: noDocs} );
      log('updated number of docs $noDocs', name: '${runtimeType.toString()}:fsDocAdd()');
    }
  }
  // Update the FirestoreDoc with data in provided Series class.
  Future<void> fsDocUpdate(FirestoreDoc fsDoc) async {
    log('fsDocUpdate: updating doc id ${fsDoc.docId}', name: '${runtimeType.toString()}:fsDocAdd()');
    return await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> fsDocDelete(FirestoreDoc fsDoc) async {
    int noDocs = -1;
    log('Database: fsDocDelete: path: ${docCollection.path} key: ${fsDoc.key} ', name: '${runtimeType.toString()}:...');
    log(docCollection.path, name: '${runtimeType.toString()}:...');
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
    log('Database: fsDocFromSnapshot: $data ... $fsDocType', name: '${runtimeType.toString()}:...');
    return FirestoreDoc( fsDocType, data: data );
  }

  // get FirestoreDoc stream
  Stream<FirestoreDoc> fsDocStream({String? key, int? docId}) {
    log('Database fsDocStream: getting player for U: $key Path: ${playerCollection.path}', name: '${runtimeType.toString()}:...');
    log('Database fsDocStream: Parent: ${docCollection.toString()} ', name: '${runtimeType.toString()}:...');
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
    log('Getting key ($key), docId is ($docId)', name: '${runtimeType.toString()}:fsDoc()');
    log(docCollection.path, name: '${runtimeType.toString()}:...');
    if (uid == 'Anonymous') {
      FirestoreDoc? empty = null;
      return Future.value(null);
    }
    FirestoreDoc? fsDoc;
    if (key != null ) {
      log('Getting doc by key: $key', name: '${runtimeType.toString()}:fsDoc()');
      await docCollection.doc(key).get()
        .then((DocumentSnapshot doc) {
          log('Doc collection from key exists: ${doc.exists}', name: '${runtimeType.toString()}:fsDoc()');
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            fsDoc = FirestoreDoc(fsDocType, data: data);
          } else {
            fsDoc = null;
          }
        },
        onError: (error) {
          log("Error getting Player UID: $uid, Error: $error", name: '${runtimeType.toString()}:fsDoc()');
          fsDoc = null;
        });
    } else if (docId != null ) {
      log('Getting doc by docId: $docId', name: '${runtimeType.toString()}:fsDoc()');
      await docCollection.where('docId', isEqualTo:docId ).get()
          .then((querySnapshot) {
        log('Doc collection from docId size: ${querySnapshot.size}', name: '${runtimeType.toString()}:...');
        if (querySnapshot.size > 0) {
          final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
          fsDoc = FirestoreDoc(fsDocType, data: data);
          log('Got Document by ID : ${fsDoc!.docId}', name: '${runtimeType.toString()}:fsDoc()');
        } else {
          fsDoc = null;
          log('No Document by ID : $docId', name: '${runtimeType.toString()}:fsDoc()');
        }
      },
          onError: (error) {
            log("Error getting Player UID: $uid, Error: $error", name: '${runtimeType.toString()}:fsDoc()');
            fsDoc = null;
          });
    } else {
      log('Error: Missing key?', name: '${runtimeType.toString()}:fsDoc()');
      fsDoc = null;
    }
    return fsDoc;
  }

  //get FirestoreDoc List stream
  Stream<List<FirestoreDoc>> get fsDocListStream {
    log('Database: fsDocListStream: ', name: '${runtimeType.toString()}:...');
    log(docCollection.path, name: '${runtimeType.toString()}:...');
    Stream<QuerySnapshot<Object?>> s001 = docCollection.snapshots();
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
    // return docCollection.snapshots()
    //   .map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
//        .map(_fsDocListFromSnapshot);
  }

  //get FirestoreDoc List stream
  Stream<List<FirestoreDoc>> fsDocGroupListStream({ required int pid, required int cid} ) {
    log('Database: fsDocGroupListStream: pid: ${pid} cid: ${cid} ', name: '${runtimeType.toString()}:...');
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
    log('Database: fsDocList: ', name: '${runtimeType.toString()}:...');
    log(docCollection.path, name: '${runtimeType.toString()}:...');
    List<FirestoreDoc> fsDocList = [];
    await docCollection.get().then((snapshot) {
      log('Database: fsDocList: Snapshot Size ${snapshot.size}', name: '${runtimeType.toString()}:...');
      for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        log('Database: fsDocList: Snapshot Doc ID:  ${doc.id}', name: '${runtimeType.toString()}:...');
        Map<String, dynamic> data =  doc.data()! as Map<String, dynamic>;
        FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
        fsDocList.add(fsDoc);
      }
       // snapshot.docs.forEach((doc) {
       // });
       log('database: fsDocList: return type ${fsDocList.runtimeType} Length: ${fsDocList.length}', name: '${runtimeType.toString()}:...');
      },
      onError: (e) => log("Error getting document: $e", name: '${runtimeType.toString()}:...'),
    );
    return fsDocList;
  }

  //get FirestoreDoc List stream
  // ToDo: Fix this.
  Future<int> get fsDocCount async {
    int docCount=0;
    log('Database: fsDocCount: ', name: '${runtimeType.toString()}:...');
    log(docCollection.path, name: '${runtimeType.toString()}:...');

    await docCollection.count().get().then((snapshot) {
      docCount = snapshot.count;
    });
    return Future<int>.value(docCount);
  }
}