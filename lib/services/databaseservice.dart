import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bruceboard/models/firestoredoc.dart';

// Todo: Convert this to a Database Factory??
class DatabaseService {
  String? uid; // Current Active User ID - This parameter never needs to be used ... as it is looked up.
  String? toUid; // Second User ID for Messages
  String? fromUid; // Second User ID for Messages
  String? sidKey; // Series ID
  String? gidKey; // Game ID (User as Game ID and Board ID)
  String? cidKey; // Player ID (Used as Member)

  String messageLocation; // Where to write / read messages (default to
  FSDocType fsDocType;

  static FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference configCollection = FirebaseFirestore.instance
      .collection('Config');

  final CollectionReference playerCollection = FirebaseFirestore.instance
      .collection('Player');

  late CollectionReference docCollection;
  late DocumentReference statsDocument;
  late DocumentReference nextIdDocument;

  FirebaseFirestore get dbInst {
    return db;
  }
  // --------------------------------------------------------------------------
  // Setup Database Services, indicated DocType and potential document Keys
  // ---
  // If UID not passed in, try to calculate it from Firebase Auth.
  // In fact you should never need to pass in UID as long as you check
  // to ensure the user is signed in or you are retreiving documents from
  // someone else's space (/Player/{other pid}
  DatabaseService(this.fsDocType, {this.toUid, this.fromUid, this.uid, this.cidKey, this.sidKey, this.gidKey, this.messageLocation = 'Incoming'}) {
    log('Player Collection ${playerCollection.path}', name: '${runtimeType.toString()}:Database()');

    if (uid == null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;
      } else {
        uid = 'Anonymous';
      }
    }
    if ( uid == null ) {
      log("Didn't get UID!!!", name: '${runtimeType.toString()}:Database()');
    }
    // if toUid not set ... set it to the current users uid.
    toUid ??= uid;
    // if toUid not set ... set it to the current users uid.
    fromUid ??= uid;

    log('Class Type is > $fsDocType', name: '${runtimeType.toString()}:Database()');
    switch (fsDocType) {
      case FSDocType.messageowner: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);  // Write stats to sending player?
        docCollection = playerCollection.doc(toUid).collection('MessageOwner');
        log('Found "MessageOwner" class', name: '${runtimeType.toString()}:Database()');
        log(docCollection.path, name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.audit: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);  // Write stats to sending player?
        docCollection = playerCollection.doc(toUid).collection('Audit');
        log('Found "Audit" class', name: '${runtimeType.toString()}:Database()');
        log(docCollection.path, name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.message: {
        nextIdDocument = playerCollection.doc(uid);  // Next number in sender Player id
        statsDocument = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid);
        docCollection = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid).collection(messageLocation);
        log('Found "Message" class : ${docCollection.path}', name: '${runtimeType.toString()}:Database()');
        log(docCollection.path, name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.player: {
        nextIdDocument = configCollection.doc('Production');
        statsDocument = configCollection.doc('Production');
        docCollection = playerCollection;
        log('Found "Player" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.series: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Series');
        log('Found "Series" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.access: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Access');
        log('Found "Access" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.game: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Game');
        log('Found "Game" class', name: '${runtimeType.toString()}:Database()');
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
        log('Found "Board" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.grid: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series')
            .doc(sidKey).collection('Game')
            .doc(gidKey);
        docCollection = playerCollection.doc(uid).collection('Series')
            .doc(sidKey).collection('Game')
            .doc(gidKey).collection('Grid');
        log('Found "Grid" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.membership: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Membership');
        log('Found "Membership" class : ${docCollection.path}', name: '${runtimeType.toString()}:Database()');
        log(docCollection.path, name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.community: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Community');
        log('Found "Membership" class', name: '${runtimeType.toString()}:Database()');
      }
      break;
      case FSDocType.member: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Community').doc(cidKey);
        docCollection = playerCollection.doc(uid).collection('Community').doc(cidKey).collection('Member');
        log('Found "Member" class', name: '${runtimeType.toString()}:Database()');
        log(docCollection.path, name: '${runtimeType.toString()}:Database()');
      }
      break;
      default: {
        log('Undefined class $fsDocType', name: '${runtimeType.toString()}:Database()');
      }
      break;
    }
    log('Setting up DatabaseService $uid', name: '${runtimeType.toString()}:Database()');
  }
// =============================================================================
//                ***   FirestoreDoc DATABASE MEMBERS   ***
// =============================================================================
  // --------------------------------------------------------------------------
  // Private method to convert a list of snapshots to a List of fsDocs
  List<FirestoreDoc> _fsDocListFromSnapshot(QuerySnapshot snapshot) {
    log('QuerySnapshot size is ${snapshot.size} UID: $uid Type: $fsDocType',
        name: '${runtimeType.toString()}:_fsDocListFromSnapshot');
    return snapshot.docs.map((doc) {
      // log("mapping docs", name: '${runtimeType.toString()}:fsDocStream()');
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
      return fsDoc;
    }).toList();
  }
  // --------------------------------------------------------------------------
  // Private function to return a fsDoc from a single snapshot
  FirestoreDoc _fsDocFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    // log('Data: $data ... $fsDocType', name: '${runtimeType.toString()}:_fsDocFromSnapshot()');
    return FirestoreDoc( fsDocType, data: data );
  }
  // --------------------------------------------------------------------------
  // Private function to Create a Query given criteria and sort order info
  Query<Object?>? _buildQuery({required Map<String, dynamic> queryValues, Map<String, dynamic>? orderFields}) {
    Query<Object?>? query;
    log('Query Vars: $queryValues ', name: '${runtimeType.toString()}:_buildQuery()');
    log('Query Path: ${docCollection.path} ', name: '${runtimeType.toString()}:_buildQuery()');
    // Build Where Query
    queryValues.forEach((key, value) {
      if (key != '' && value != '') {
        if (query == null) {
          query = docCollection.where(key.toString(), isEqualTo: value);
        } else {
          query = query!.where(key.toString(), isEqualTo: value);
        }
        // ignore: empty_statements
      };
    });
    // Add Order Options if they exists
    if (orderFields != null) {
      orderFields.forEach((fld, descending) {
        if (fld != '' && descending != '') {
          query = docCollection.orderBy(fld.toString(), descending: descending);
        }
      });
    }
    // If no query parameters ... return full collection
    query ??= docCollection;
    return query;
  }
  // ---------------------------------------------------------------------------
  // Add and fsDoc to the Firestore for given Type
  // Get the nextNumber for the type and increment it.
  Future<void> fsDocAdd(FirestoreDoc fsDoc) async {
    //int noDocs = -1;
    // If there is already a docId, use it vs getting the Next Number
    log("Adding documnet : ${fsDoc.docId}", name: '${runtimeType.toString()}:fsDocAdd');
    if (fsDoc.docId == -1) {
      // Get the next FirestoreDoc number for the player
      log('Creating new key', name: '${runtimeType.toString()}:fsDocAdd');
      log(nextIdDocument.path, name: '${runtimeType.toString()}:fsDocAdd');
      await nextIdDocument.get().then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        fsDoc.docId = data[fsDoc.nextIdField] ?? 0;  // If nextSid not found, start at 0.
      },
          onError: (e) {
            log("Error getting Player Next Series ID: $e", name: '${runtimeType.toString()}:fsDocAdd');
            fsDoc.docId = 9999;
          }
      );
      // *********
      // Note: The Get Next Number and Increment should be wrapped in a transaction to
      // avoid the number being "GOT" by user and cloud simultaneously.
      // If this occurs, the result would be a overwritten record.  This would be most likely
      // for Audit records as these are Created by Cloud Functions as well as the client app.
      // Todo: Wrap get nextNumber & update in a Transaction
      // log('Message: fsDocAdd: fsDoc Type: ${fsDoc.runtimeType} fsDocId: ${fsDoc.docId} ');
      // Set or Increment the next Series number
      if ( fsDoc.docId == 0 ) {
        await nextIdDocument.update( {fsDoc.nextIdField: 1}, );
      } else {
        await nextIdDocument.update( {fsDoc.nextIdField: FieldValue.increment(1)}, );
      }
    }
    // log('Updating Firebase ${fsDoc.updateMap}');
    log('Adding document ${fsDoc.runtimeType} Key: ${fsDoc.key}', name: '${runtimeType.toString()}:fsDocAdd');
    log(docCollection.path, name: '${runtimeType.toString()}:fsDocAdd');
    await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
    // await docCollection.count().get()
    //     .then((res) => noDocs = res.count ?? -1,
    // );
    if (fsDoc.totalField != 'NO-TOTALS') {
      log('Updating number of docs', name: '${runtimeType.toString()}:fsDocAdd()');
      log(statsDocument.path, name: '${runtimeType.toString()}:fsDocAdd');
      // await statsDocument.update({ fsDoc.totalField: noDocs} );
      await statsDocument.update({ fsDoc.totalField: FieldValue.increment(1)} );
    }
  }
  // --------------------------------------------------------------------------
  // Update the FirestoreDoc with data in provided fsDoc.
  Future<void> fsDocUpdate(FirestoreDoc fsDoc) async {
    log('Updating doc id ${fsDoc.docId}', name: '${runtimeType.toString()}:fsDocAdd()');
    return await docCollection.doc(fsDoc.key).set(fsDoc.updateMap, SetOptions(merge: true));
  }
  // --------------------------------------------------------------------------
  // Update single field in an FirestoreDoc
  Future<void> fsDocUpdateField({required String key, required String field, String? svalue, int? ivalue, bool? bvalue}) async {
    log('Database *key*: "$key" Update *field*: "$field" *value*: ${ivalue ?? svalue ?? bvalue} uid: $uid',
        name: '${runtimeType.toString()}:fsDocUpdateField()');
    return await docCollection.doc(key).update({
      field: svalue ?? ivalue ?? bvalue,
    });
  }
// Todo: Add fsDocIncrementField(field, value)

  // --------------------------------------------------------------------------
  // Note: Application is responsible to delete underlying documents before deleting this document
  // Id does not do a cascade delete.
  Future<void> fsDocDelete(FirestoreDoc fsDoc) async {
    // int noDocs = -1;
    log('Path: ${docCollection.path} key: ${fsDoc.key} ', name: '${runtimeType.toString()}:fsDocDelete');
    log(docCollection.path, name: '${runtimeType.toString()}:fsDocDelete');
    await docCollection.doc(fsDoc.key).delete();
    // fsDoc = FirestoreDoc(data: {});  // Clear out the class?

    if (fsDoc.totalField != 'NO-TOTALS') {
      // await docCollection.count().get()
      //     .then((res) => noDocs = res.count ?? -1,
      // );
      // await statsDocument.update({ fsDoc.totalField: noDocs} );
      log('Updating number of docs', name: '${runtimeType.toString()}:fsDocDelete()');
      await statsDocument.update({ fsDoc.totalField: FieldValue.increment(-1)} );
    }
  }
  // --------------------------------------------------------------------------
  // Return a Stream fsDoc given a Key or DocId
  // If neither a Key or DocId is provided, an Empty Stream is returned.
  Stream<FirestoreDoc> fsDocStream({String? key, int? docId}) {
    // log('Getting player for U: $key Path: ${playerCollection.path}', name: '${runtimeType.toString()}:fsDocStream()');
    // log('Parent: ${docCollection.toString()} ', name: '${runtimeType.toString()}:fsDocStream()');
    Stream<FirestoreDoc> fsDocStream;
    if (key != null) {
      fsDocStream = docCollection.doc(key).snapshots()
          .map((DocumentSnapshot doc) => _fsDocFromSnapshot(doc));
    } else if (docId != null) {
      // Note ... only 1 document matches the docId so select the first ...
      fsDocStream = docCollection.where('docId', isEqualTo:docId ).snapshots()
          .map((QuerySnapshot doc) => _fsDocFromSnapshot(doc.docs.first));
    } else {
      fsDocStream = const Stream.empty();
    }
    return fsDocStream;
  }
  // --------------------------------------------------------------------------
  // Return a Future fsDoc given a Key or DocId
  // If neither a Key or DocId is provided, a default fsDoc is return with a -1 docId.
  Future<FirestoreDoc?> fsDoc({String? key, int? docId}) async {
    log('Getting key ($key), docId is ($docId)', name: '${runtimeType.toString()}:fsDoc()');
    log(docCollection.path, name: '${runtimeType.toString()}:fsDoc()');
    // Set fsDoc to an invalid document
    FirestoreDoc? fsDoc = FirestoreDoc(fsDocType, data: {'docID': -1} );
    // ToDo: See where this is used, think about returning Null?
    if (uid == 'Anonymous') {
      log('Return null as user $uid', name: '${runtimeType.toString()}:fsDoc()');
      return fsDoc;
    }
    // Check for Key
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
    // Else check for docId
    } else if (docId != null ) {
      log('Getting doc by docId: $docId', name: '${runtimeType.toString()}:fsDoc()');
      await docCollection.where('docId', isEqualTo:docId ).get()
        .then((querySnapshot) {
        log('Doc collection from docId size: ${querySnapshot.size}', name: '${runtimeType.toString()}:fsDoc()');
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
        log("Error getting Doc UID: $uid, Error: $error", name: '${runtimeType.toString()}:fsDoc()');
        fsDoc = null;
      });
    } else {
      log('Error: Missing key?', name: '${runtimeType.toString()}:fsDoc()');
      fsDoc = null;
    }
    return fsDoc;
  }
  // --------------------------------------------------------------------------
  // Return a Stream of List of fsDocs for given Collection
  Stream<List<FirestoreDoc>> get fsDocListStream {
    log('Database: fsDocListStream: ', name: '${runtimeType.toString()}:get fsDocListStream');
    log(docCollection.path, name: '${runtimeType.toString()}:get fsDocListStream');
    Stream<QuerySnapshot<Object?>> s001 = docCollection.snapshots();
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
  }
  // --------------------------------------------------------------------------
  // Return a Stream List of docs given the query info.
  Stream<List<FirestoreDoc>> fsDocQueryListStream({required Map<String, dynamic> queryValues, Map<String, dynamic>? orderFields}) {

    Stream<QuerySnapshot<Object?>> s001;
    Query<Object?>? query;

    query = _buildQuery(queryValues: queryValues, orderFields: orderFields);

    // If no query parameters ... return full collection
    if (query == null) {
      s001 = docCollection.snapshots();
    } else {
      s001 = query.snapshots();
    }
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
  }
  // --------------------------------------------------------------------------
  // Return a Future List of docs given the query info.
  Future<List<FirestoreDoc>> fsDocQueryList({required Map<String, dynamic> queryValues, Map<String, dynamic>? orderFields}) async {
    List<FirestoreDoc> fsDocList = [];
    Query<Object?>? query;

    query = _buildQuery(queryValues: queryValues, orderFields: orderFields);

    await query!.get().then((snapshot) {
      log('Snapshot Size ${snapshot.size}', name: '${runtimeType.toString()}:get fsDocList');
      for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        log('Snapshot Doc ID:  ${doc.id}', name: '${runtimeType.toString()}:get fsDocList');
        Map<String, dynamic> data =  doc.data()! as Map<String, dynamic>;
        FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
        fsDocList.add(fsDoc);
      }
      log('Return type ${fsDocList.runtimeType} Length: ${fsDocList.length}', name: '${runtimeType.toString()}:fsDocQueryList()');
    },
      onError: (e) => log("Error getting document: $e", name: '${runtimeType.toString()}:fsDocQueryList()'),
    );
    return fsDocList;
  }
  // --------------------------------------------------------------------------
  // Return a Future List of fsDocs for the givne Group Access
  // Note: Not Tested ...
  // ToDo: Update for Incoming and Processed Groups ... see Stream.
  Future<List<FirestoreDoc>> fsDocGroupList(String group, {required Map<String, dynamic> queryFields, Map<String, dynamic>? orderFields }) async {
    late Query<Object?> query;
    List<FirestoreDoc> fsDocList = [];

    log('fsDocGroupList: Group: $group, $queryFields',
        name: '${runtimeType.toString()}:fsDocGroupList()');

    switch (group) {
      case "Game" :
        log("Group: $group ...", name: '${runtimeType.toString()}:fsDocGroupList()');
        query = db.collectionGroup("Game");
        break;
      case "Access" :
        log("Group: $group ...", name: '${runtimeType.toString()}:fsDocGroupList()');
        query = db.collectionGroup("Access");
        break;
      default: {
        log('Error: Undefined group $group', name: '${runtimeType.toString()}:fsDocGroupList()');
        return fsDocList;
      }
    }

    queryFields.forEach((field, value) {
      if (field != '' && value != '') {
        log("Select - Field: $field, Value: $value ...", name: '${runtimeType.toString()}:fsDocGroupList()');
        query = query.where(field.toString(), isEqualTo: value);
        // ignore: empty_statements
      };
    });
    // Add order Options if they exists
    if (orderFields != null) {
      orderFields.forEach((field, descending) {
        if (field != '' && descending != '') {
          log("Order - Field: $field, Value: $descending ...", name: '${runtimeType.toString()}:fsDocGroupList()');
          query = query.orderBy(field.toString(), descending: descending);
        }
      });
    }
    await query.get().then((snapshot) {
      log('Snapshot Size ${snapshot.size}', name: '${runtimeType.toString()}:get fsDocList');
      for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        log('Snapshot Doc ID:  ${doc.id}', name: '${runtimeType.toString()}:get fsDocList');
        Map<String, dynamic> data =  doc.data()! as Map<String, dynamic>;
        FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
        fsDocList.add(fsDoc);
      }
      log('Return type ${fsDocList.runtimeType} Length: ${fsDocList.length}', name: '${runtimeType.toString()}:fsDocGroupList()');
    },
      onError: (e) => log("Error getting document: $e", name: '${runtimeType.toString()}:fsDocGroupList()'),
    );
    return fsDocList;
  }
  // --------------------------------------------------------------------------
  // Return a Stream List of fsDocs given the query data
  Stream<List<FirestoreDoc>> fsDocGroupListStream(String group, {required Map<String, dynamic> queryFields, Map<String, dynamic>? orderFields }) {
    Stream<QuerySnapshot<Object?>>? streamQuerySnapshot;
    late Query<Object?> query;

    log('fsDocGroupListStream2: Group: $group, $queryFields',
        name: '${runtimeType.toString()}:fsDocGroupListStream()');

    switch (group) {
      case "Game" :
        log("Group: $group ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
        query = db.collectionGroup("Game");
        break;
      case "Access" :
        log("Group: $group ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
        query = db.collectionGroup("Access");
        break;
      case "Incoming" :
        log("Incoming: $group ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
        query = db.collectionGroup("Incoming");
        break;
      case "Processed" :
        log("Group: $group ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
        query = db.collectionGroup("Processed");
        break;
      default: {
        log('Error: Undefined group $group', name: '${runtimeType.toString()}:fsDocGroupListStream()');
        return const Stream<List<FirestoreDoc>>.empty();
      }
    }
    queryFields.forEach((field, value) {
      if (field != '' && value != '') {
        log("Select - Field: $field, Value: $value ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
        query = query.where(field.toString(), isEqualTo: value);
        // ignore: empty_statements
      };
    });
    // Add order Options if they exists
    if (orderFields != null) {
      orderFields.forEach((field, descending) {
        if (field != '' && descending != '') {
          log("Order - Field: $field, Value: $descending ...", name: '${runtimeType.toString()}:fsDocGroupListStream()');
          query = query.orderBy(field.toString(), descending: descending);
        }
      });
    }
    streamQuerySnapshot = query.snapshots();
    return streamQuerySnapshot.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
  }
  // --------------------------------------------------------------------------
  // Return Future List of fsDocs for the defined type
  Future<List<FirestoreDoc>> get fsDocList async {
    log('Database: fsDocList: ', name: '${runtimeType.toString()}:get fsDocList');
    log(docCollection.path, name: '${runtimeType.toString()}:get fsDocList');
    List<FirestoreDoc> fsDocList = [];
    await docCollection.get().then((snapshot) {
      log('Snapshot Size ${snapshot.size}', name: '${runtimeType.toString()}:get fsDocList');
      for (QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        log('Snapshot Doc ID:  ${doc.id}', name: '${runtimeType.toString()}:get fsDocList');
        Map<String, dynamic> data =  doc.data()! as Map<String, dynamic>;
        FirestoreDoc fsDoc = FirestoreDoc( fsDocType, data: data );
        fsDocList.add(fsDoc);
      }
       // snapshot.docs.forEach((doc) {
       // });
       log('Return type ${fsDocList.runtimeType} Length: ${fsDocList.length}', name: '${runtimeType.toString()}:get fsDocList');
      },
      onError: (e) => log("Error getting document: $e", name: '${runtimeType.toString()}:get fsDocList'),
    );
    return fsDocList;
  }
  // --------------------------------------------------------------------------
  // Return a Future of the number of documents
  Future<int> get fsDocCount async {
    int docCount=0;
    log('Database: fsDocCount: ', name: '${runtimeType.toString()}:get fsDocCount');
    log(docCollection.path, name: '${runtimeType.toString()}:get fsDocCount');

    await docCollection.count().get().then((snapshot) {
      docCount = snapshot.count ?? -1;
    });
    return Future<int>.value(docCount);
  }
  // --------------------------------------------------------------------------
  // Update the noMessages field for the given player in the Player docu.
  Future<void> noMessageSync({required pid}) async {
    if (FSDocType.message ==fsDocType ) {
      Query<Object?>query = db.collectionGroup("Incoming").where("pidTo", isEqualTo: pid);
      QuerySnapshot<Object?> snapshots = await query.get();
      log('Snapshot Size ${snapshots.size}',
          name: '${runtimeType.toString()}:noMessageSync');
      await playerCollection.doc(toUid)
          .update({ "noMessages": snapshots.size});
    } else {
      log('Function must be called with FSDocType.message',
          name: '${runtimeType.toString()}:noMessageSync');
    }
  }
}