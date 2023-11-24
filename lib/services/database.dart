import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/player.dart';

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
  //late Player _player;
  // FirestoreDoc fsDoc;
  FSDocType fsDocType;

//  FirebaseFirestore db;
  final CollectionReference configCollection = FirebaseFirestore.instance
      .collection('Config');

  final CollectionReference playerCollection = FirebaseFirestore.instance
      .collection('Player');

  final Query messageQuery = FirebaseFirestore.instance.collectionGroup('Incoming');

  late CollectionReference docCollection;
  late DocumentReference statsDocument;
  late DocumentReference nextIdDocument;

  DatabaseService(this.fsDocType, { this.toUid, this.fromUid, this.uid, this.cidKey, this.sidKey, this.gidKey }) {
    // If UID not passed in, try to calculate it from Firebase Auth.
    // In fact you should never need to pass in UID as long as you check
    // to ensure the user is signed in.
    log('Player Collection ${playerCollection.path}');

    if (uid == null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) uid = user.uid;
    }
    // if toUid not set ... set it to the current users uid.
    if (toUid == null) {
      toUid = uid;
    }
    // if toUid not set ... set it to the current users uid.
    if (fromUid == null) {
      fromUid = uid;
    }
    log('DatabaseService: Class Type is > $fsDocType');
    switch (fsDocType) {
      case FSDocType.messageowner: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(toUid).collection('MessageOwner');
        //.doc(uid).collection('Incoming');
        log('Database: Found "MessageOwber" class');
      }
      break;
      case FSDocType.message: {
        nextIdDocument = playerCollection.doc(toUid);
        statsDocument = playerCollection.doc(toUid);
        docCollection = playerCollection.doc(toUid).collection('MessageOwner').doc(fromUid).collection('Incoming');
        log('Database: Found "Message" class');
      }
      break;
      case FSDocType.player: {
        nextIdDocument = configCollection.doc('Production');
        statsDocument = configCollection.doc('Production');
        docCollection = playerCollection;
        log('Database: Found "Player" class');
      }
      break;
      case FSDocType.series: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Series');
        log('Database: Found "Series" class');
      }
      break;
      case FSDocType.game: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Series').doc(sidKey);
        docCollection = playerCollection.doc(uid).collection('Series').doc(sidKey).collection('Game');
        log('Database: Found "Game" class');
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
        log('Database: Found "Board" class');
      }
      break;
      case FSDocType.membership: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Membership');
        log('Database: Found "Membership" class');
      }
      break;
      case FSDocType.community: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid);
        docCollection = playerCollection.doc(uid).collection('Community');
        log('Database: Found "Membership" class');
      }
      break;
      case FSDocType.member: {
        nextIdDocument = playerCollection.doc(uid);
        statsDocument = playerCollection.doc(uid).collection('Community').doc(cidKey);
        docCollection = playerCollection.doc(uid).collection('Community').doc(cidKey).collection('Member');
        log('Database: Found "Member" class');
      }
      break;
      default: {
        log('MessageSerive: Undefined class $fsDocType');
      }
      break;
    }
    log('Setting up DatabaseService $uid');
  }

// =============================================================================
//                ***   FirestoreDoc DATABASE MEMBERS   ***
// =============================================================================
  Future<void> fsDocAdd(FirestoreDoc fsDoc) async {
    int noDocs = -1;
    // If there is already a docId, use it vs getting the Next Number
    if (fsDoc.docId == -1) {
      // Get the next series number for the player
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
      if (fsDoc.docId == 0 ) {
        await nextIdDocument.update( {fsDoc.nextIdField: 1}, );
      } else {
        await nextIdDocument.update( {fsDoc.nextIdField: FieldValue.increment(1)}, );
      }
    }
    // log('Updating Firebase ${fsDoc.updateMap}');
    await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    await statsDocument.update({ fsDoc.totalField: noDocs} );
  }
  // Update the series Doc with data in provided Series class.
  Future<void> fsDocUpdate(FirestoreDoc fsDoc) async {
    return await docCollection.doc(fsDoc.key).set(fsDoc.updateMap);
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> fsDocDelete(FirestoreDoc fsDoc) async {
    int noDocs = -1;

    await docCollection.doc(fsDoc.key).delete();
    // fsDoc = FirestoreDoc(data: {});  // Clear out the class?
    await docCollection.count().get()
        .then((res) => noDocs = res.count,
    );
    await statsDocument.update({
      fsDoc.totalField: noDocs}
    );
  }

  // Series list from snapshot
  List<FirestoreDoc> _fsDocListFromSnapshot(QuerySnapshot snapshot) {
    //seriesCollection = playerCollection.doc(uid).collection('Series');
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
    log('fsDocFromSnapshot $data ... $fsDocType');
    return FirestoreDoc( fsDocType, data: data );
  }

  // get FirestoreDoc stream
  Stream<FirestoreDoc> fsDocStream({ required String key }) {
    // log('database fsDocStream: getting player for U: ${key} Path: ${playerCollection.path}');
    // log('database fsDocStream: Parent: ${docCollection.toString()} ');
    return docCollection.doc(key).snapshots()
        .map((DocumentSnapshot doc) => _fsDocFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }

  Future<FirestoreDoc?> fsDoc({required String key}) async {
    FirestoreDoc? fsDoc;
    await docCollection.doc(key).get()
      .then((DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        fsDoc = FirestoreDoc(fsDocType, data: data);
      },
    onError: (error) {
      log("Error getting Player UID: $uid, Error: $error");
      fsDoc = null;
    });
    return fsDoc;
  }

  //get FirestoreDoc List stream
  Stream<List<FirestoreDoc>> get fsDocList {
    Stream<QuerySnapshot<Object?>> s001 = docCollection.snapshots();
    return s001.map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
    // return docCollection.snapshots()
    //   .map((QuerySnapshot snapshot) => _fsDocListFromSnapshot(snapshot));
//        .map(_fsDocListFromSnapshot);
  }

// // =============================================================================
// //               ***   PLAYER DATABASE MEMBERS   ***  (DONE)
// // =============================================================================
//   // Update Player
//   // Future<void> updatePlayer(String fName, String lName, String initials, int pid) async {
//   //  Future<void> updatePlayer({ required Player player }) async {
//     Future<void> updatePlayer(Player player) async {
//     //int playerNo = 0;
//     //log('Database: Update Player ... ${player.fName}');
//     if (player.pid == -1) {
//       log('database:updatePlayer: Creating new player U:${player.uid} P:${player.pid} D:${player.docId}');
//       // Get the next player number
//       await nextIdDocument.get().then(
//               (DocumentSnapshot doc) {
//             // log("Production Snapshot Data: ${doc.data}");
//             final data = doc.data() as Map<String, dynamic>;
//             player.pid = data[player.nextIdField] ?? 0;
//             player.docId = player.pid;     // Start at player 0.
//           },
//           onError: (e) {
//             log("Error getting Player Next Number: $e");
//             player.pid = -1;
//           }
//       );
//       // Increment the next player number
//       await parentCollection.doc('Production').update(
//         { player.nextIdField: FieldValue.increment(1) },
//       );
//     }
//     // log("Player update map ${_player.updateMap}");
//     return await playerCollection.doc(uid).set(player.updateMap, SetOptions(merge: true));
//     //return await playerCollection.doc(uid).set(_player.updateMap);
//   }
//
//   // Update single field in Series doc
//   Future<void> updatePlayerField({
//   required String field,
//     String? svalue,
//     int? ivalue,
//   }) async {
//     log('Database Update Player *field*: "$field" *value*: ${ivalue ?? svalue} uid: $uid');
//     return await playerCollection.doc(uid).update({
//       field: svalue ?? ivalue,
//     });
//   }
//
//   // Player list from snapshot
//   List<Player> _playerListFromSnapshot(QuerySnapshot snapshot) {
//     if (uid != null ) {
//       return snapshot.docs.map((doc) {
//         //print(doc.data);
//         Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//         return Player( data: data );
//       }).toList();
//     } else {
//       return [];
//     }
//   }
//
//   // Player data from snapshots
//   Player _playerFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     //log("Getting player from snapshot ${data}");
//     if (uid != null) {
//       //log("Player : ${data['fName']}");
//       return Player(data: data);
//     } else {
//       log('_playerFromSnapshot: Error: UID Not Set');
//       return Player(data: { 'uid': 'x', 'pid': -1,
//         'fName': 'null', 'lName': 'null', 'initials': 'nn' }
//       );
//     }
//   }
//
//   // Get players stream
//   Stream<List<Player>> get playerListStream {
//     return playerCollection.snapshots()
//       .map(_playerListFromSnapshot);
//   }
//
//   // get player doc stream
//   Stream<Player> get playerStream {
//     return playerCollection.doc(uid).snapshots()
//     .map((DocumentSnapshot doc) => _playerFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//   }
//   // get player doc stream
//   Player? get player {
//
//     //log('Database: player: Getting Player for $uid');
//     playerCollection.doc(uid).get()
//       .then((DocumentSnapshot doc) {
//
//         final data = doc.data() as Map<String, dynamic>;
//
//         Player player = Player(data: data);
//
//         log('Database: player: Got Player ${player.fName} NoMemberships: ${player.noMemberships}');
//         return(player);
//       },
//     onError: (error) {
//       log("Error getting Player UID: $uid, Error: $error");
//       return null;
//     });
//     return null;
//   }
//
// // =============================================================================
// //                ***   SERIES DATABASE MEMBERS   ***  (DONE)
// // =============================================================================
//   Future<void> addSeries({ required Series series,} ) async {
//     int noSeries = -1;
//     // Get the next series number for the player
//     await playerCollection.doc(uid).get().then((DocumentSnapshot doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         series.sid = data['nextSid'] ?? 0;  // If nextSid not found, start at 0.
//       },
//         onError: (e) {
//           log("Error getting Player Next Series ID: $e");
//           series.sid = 9999;
//         }
//     );
//     // Set or Increment the next Series number
//     if (series.sid == 0 ) {
//       await playerCollection.doc(uid).update(
//         {"nextSid": 1},
//       );
//     } else {
//       await playerCollection.doc(uid).update(
//         {"nextSid": FieldValue.increment(1)},
//       );
//     }
//
//     await seriesCollection.doc(series.key).set(series.updateMap);
//     await seriesCollection.count().get()
//         .then((res) => noSeries = res.count,
//     );
//     await playerCollection.doc(uid).update({
//       "noSeries": noSeries}
//     );
//   }
//   // Update the series Doc with data in provided Series class.
//   Future<void> updateSeries({ required Series series,}) async {
//     return await seriesCollection.doc(series.key).set(series.updateMap);
//   }
//
//   // Delete given Series
//   // Note: Application is responsible to delete Games prior to this call!!
//   Future<void> deleteSeries(String sidKey) async {
//     int noSeries = -1;
//
//     await seriesCollection.doc(sidKey).delete();
//     await seriesCollection.count().get()
//         .then((res) => noSeries = res.count,
//     );
//     await playerCollection.doc(uid).update({
//       "noSeries": noSeries}
//     );
//   }
//
//   // Series list from snapshot
//   List<Series> _seriesListFromSnapshot(QuerySnapshot snapshot) {
//     //seriesCollection = playerCollection.doc(uid).collection('Series');
//     log('Series Size is ${snapshot.size} UID: $uid');
//     return snapshot.docs.map((doc) {
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       Series series = Series( data: data );
//       return series;
//     }).toList();
//   }
//
//   // Get Series data from snapshots
//   Series _seriesFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     return Series( data: data );
//   }
//
//   //get collections stream
//   Stream<List<Series>> get seriesList {
//     return seriesCollection.snapshots()
//         .map(_seriesListFromSnapshot);
//   }
// // =============================================================================
// //                ***   GAME DATABASE MEMBERS   *** (DONE)
// // =============================================================================
//   // Update Game
//   Future<void> addGame( { required Game game } ) async  {
//     int noGames = -1;
//     // Get the next series number for the player
//     await playerCollection.doc(uid).get().then((DocumentSnapshot doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       game.gid = data['nextGid'] ?? 0;  // If nextGid not found, start at 0.
//     },
//       onError: (e) {
//         log("Error getting Series Next Game ID: $e");
//         game.gid = 9999;
//       }
//     );
//     // Set or Increment the next Game number
//     if (game.gid == 0 ) {
//       await playerCollection.doc(uid).update(
//         {"nextGid": 1},
//       );
//     } else {
//       await playerCollection.doc(uid).update(
//         {"nextGid": FieldValue.increment(1)},
//       );
//     }
//
//     log("Adding game for key ${game.key}");
//     await gameCollection.doc(game.key).set(game.updateMap);
//     await gameCollection.count().get()
//         .then((res) => noGames = res.count,
//     );
//     await seriesCollection.doc(sidKey).update({
//       "noGames": noGames}
//     );
//   }
//
//   // Update the game Doc with data in provided Game class.
//   Future<void> updateGame({ required Game game,}) async {
//     return await gameCollection.doc(game.key).set(game.updateMap);
//   }
//
//   // Delete given Game
//   // Note: Application is responsible to delete the associated Board prior to this call!!
//   Future<void> deleteGame(String gidKey) async {
//     int noGames = -1;
//     await gameCollection.doc(gidKey).delete();
//     await gameCollection.count().get()
//         .then((res) => noGames = res.count,
//     );
//     await seriesCollection.doc(sidKey).update({
//       "noGames": noGames
//     });
//   }
//
//   // Game list from snapshot
//   List<Game> _gameListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs.map((doc) {
//       //print(doc.data);
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       return Game( data: data );
//     }).toList();
//   }
//
//   // Game data from snapshots
//   Game _gameFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     return Game( data: data );
//   }
//
//   //get collections stream
//   Stream<List<Game>> get gameList {
//     return gameCollection.snapshots()
//         .map(_gameListFromSnapshot);
//   }
//
//   // get game doc stream
//   Stream<Game> get game {
//     return gameCollection.doc(sidKey).snapshots()
//         .map((DocumentSnapshot doc) => _gameFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//   }
// =============================================================================
//                ***   BOARD DATABASE MEMBERS   *** (DONE)
// =============================================================================
  // Update Board
  // Note form Board, the Board  ID (bid) is equal to the Game ID so the
  // 'add'member function uses the 'set' command using the gidKey as the unique number.
//   Future<void> addBoard({
//     required String gidKey,
//         }) async {
//
//     // Defaults for new board
//     List<int> boardData = List<int>.filled(100, -1);
//     List<int> rowScores = List<int>.filled(10, -1);
//     List<int> colScores = List<int>.filled(10, -1);
//     List<int> rowResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
//     List<int> colResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
//     List<int> percentSplits = List<int>.filled(5, 20); // Q1, Q2, Q3, Q4, Community
//
//     return await boardCollection.doc(gidKey).set({
// //      'gid' : gid,
//       'boardData'     : boardData,
//       'rowScores'     : rowScores,
//       'colScores'     : colScores,
//       'rowResults'    : rowResults,
//       'colResults'    : colResults,
//       'percentSplits' : percentSplits,
//     });
//   }
//
//   Future<void> updateBoard({
//     required String field,
//     required String value,
//         }) async {
//
//     if (gidKey != null) {
//       return await boardCollection.doc(gidKey).set({
//         field: value,
//       });
//     } else {
//       // Todo: Throw an error here?
//       return;
//     }
//   }
//
//   // Delete given Board
//   Future<void> deleteBoard() async {
//     if (gidKey != null ) {
//       return await boardCollection.doc(gidKey).delete();
//     } else {
//       log('DatabaseService: deleteGame missing Game ID');
//     }
//   }
//
//   // Game list from snapshot
//   List<Board> _boardListFromSnapshot(QuerySnapshot snapshot) {
//
//     return snapshot.docs.map((doc) {
//       //print(doc.data);
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       return Board(data: data);
//     }).toList();
//   }
//
//   // Game data from snapshots
//   Board _boardFromSnapshot(DocumentSnapshot snapshot) {
//
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//
//     Board board = Board(data: data);
//
//     board.boardData = data['boardData'].cast<int>();
//     board.rowScores = data['rowScores'].cast<int>();
//     board.rowResults = data['rowResults'].cast<int>();
//     board.colScores = data['colScores'].cast<int>();
//     board.rowResults = data['rowResults'].cast<int>();
//     board.percentSplits = data['percentSplits'].cast<int>();
//     board.dirty = false;
//
//     return board;
//   }
//
//   //get collections stream
//   Stream<List<Board>> get boardList {
//
//     if (gidKey != null) {
//       return boardCollection.snapshots()
//           .map(_boardListFromSnapshot);
//     } else {
//       return const Stream.empty();
//     }
//   }
//
//   // get game doc stream
//   Stream<Board> get board {
//     log("Getting board for GID: $gidKey, UID: $uid, SID: $sidKey");
//     return boardCollection.doc(gidKey).snapshots()
//         .map((DocumentSnapshot doc) => _boardFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//   }
//
// // =============================================================================
// //                ***   COMMUNITY DATABASE MEMBERS   *** (DONE)
// // =============================================================================
//   Future<void> addCommunity({ required Community community }) async {
//     int noCommunities = -1;
//     // Get the next community number for the player
//     await playerCollection.doc(uid).get().then((DocumentSnapshot doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       community.cid = data['nextCid'] ?? 0;  // If nextCid not found, start at 0.
//     },
//         onError: (e) {
//           log("Error getting Player Next Community ID: $e");
//           community.cid = 9999;
//         }
//     );
//     // Set or Increment the next player number
//     if (community.cid == 0 ) {
//       await playerCollection.doc(uid).update(
//         {"nextCid": 1},
//       );
//     } else {
//       await playerCollection.doc(uid).update(
//         {"nextCid": FieldValue.increment(1)},
//       );
//     }
//
//     await communityCollection.doc(community.key).set(community.updateMap);
//     await communityCollection.count().get()
//         .then((res) => noCommunities = res.count,
//     );
//     await playerCollection.doc(uid).update({
//       "noCommunities": noCommunities}
//     );
//   }
//
//   Future<void> updateCommunity({required Community community}) async {
//     int noCommunities = -1;
//     await communityCollection.doc(community.key).set(community.updateMap);
//   }
//
//   // Update single field in Series doc
//   Future<void> updateCommunityField({
//     required String cidKey,
//     required String field,
//     String? svalue,
//     int? ivalue,
//   }) async {
//
//     return await communityCollection.doc(cidKey).update({
//       field: svalue ?? ivalue,
//     });
//   }
//
//   // increment / decriment Number of Members
//   // Future<void> incrementCommunityNoMembers(int val) async {
//   //
//   //   return await communityCollection.doc(cid).update(
//   //       {"noMembers": FieldValue.increment(val)});
//   // }
//
//   // Delete given Series
//   // Note: Application is responsible to delete Games prior to this call!!
//   Future<void> deleteCommunity(String cidKey) async {
//     int noCommunities = -1;
//     log('database: deleteCommunity: Deleting community $cidKey');
//     await communityCollection.doc(cidKey).delete();
//     await communityCollection.count().get()
//         .then((res) => noCommunities = res.count,
//     );
//     await playerCollection.doc(uid).update( {"noCommunities": noCommunities} );
//   }
//
//   // Community list from snapshot
//   List<Community> _communityListFromSnapshot(QuerySnapshot snapshot) {
//     log('Community Size is ${snapshot.size} UID: $uid');
//     return snapshot.docs.map((doc) {
//       //print(doc.data);
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       Community community = Community(data: data);
//       return community;
//     }).toList();
//   }
//
//   // Get Series data from snapshots
//   Community _communityFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     return Community(data: data);
//   }
//
//   //get collections stream
//   Stream<List<Community>> get communityList {
//     return communityCollection.snapshots()
//         .map(_communityListFromSnapshot);
//   }
//
//   // Get Community Doc stream
//   Stream<Community> get communityStream {
//     if (cidKey != null) {
//       return communityCollection.doc(cidKey).snapshots()
//           .map((DocumentSnapshot doc) => _communityFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//     } else {
//       log('database: Something went wrong for get community, cidKey: $cidKey');
//       // Todo: Throw an error here?
//       return const Stream.empty();
//     }
//   }
//
//   // get player doc stream
//   Community? get community {
//     communityCollection.doc(cidKey).get()
//         .then((DocumentSnapshot doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           log('database: Got Community: ${data['name']}, CID: ${doc.id}');
//           return Community(data: data);
//     },
//         onError: (error) {
//           log("Error getting Player UID: $uid, Error: $error");
//           return null;
//         });
//     return null;
//   }
// // =============================================================================
// //                ***   MEMBER DATABASE MEMBERS   *** (DONE)
// // =============================================================================
//   // Todo: change parameters to required named parameters.
//   // Update Series
//   Future<void> addMember({ required Member member }) async {
//     int noMembers = -1;
//     // Get the next Member number for the player
//     await playerCollection.doc(uid).get().then((DocumentSnapshot doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       member.mid = data['nextMid'] ?? 0;  // If nextMid not found, start at 0.
//     },
//         onError: (e) {
//           log("Error getting Player Next Member ID: $e");
//           member.mid = 9999;
//         }
//     );
//     // Set or Increment the next Member number
//     if (member.mid == 0 ) {
//       await playerCollection.doc(uid).update(
//         {"nextMid": 1},
//       );
//     } else {
//       await playerCollection.doc(uid).update(
//         {"nextMid": FieldValue.increment(1)},
//       );
//     }
//
//     await memberCollection.doc(member.key).set(member.updateMap);
//     await memberCollection.count().get()
//         .then((res) => noMembers = res.count,
//     );
//     await communityCollection.doc(cidKey).update({
//       "noMembers": noMembers}
//     );
//
//   }
//   // Update Member document
//   Future<void> updateMember({ required Member member }) async {
//     await memberCollection.doc(member.key).set(member.updateMap);
//
//   }
//
//   // increment / decriment Number of Members (Note MID = PID)
//   Future<void> incrementMemberCredits({required String pidKey, required int val}) async {
//
//     return await memberCollection.doc(pidKey).update(
//         {"credits": FieldValue.increment(val)});
//   }
//
//   // Delete given the Player ID (which is the Document Reference for Members)
//   // Note: Application should check to see if the Member is associate with any
//   // active boards else this will be lost?
//   Future<void> deleteMember(String pidKey) async {
//     return await memberCollection.doc(pidKey).delete();
//   }
//
//   // Member list from snapshot
//   List<Member> _memberListFromSnapshot(QuerySnapshot snapshot) {
//     log('Member Size is ${snapshot.size} cidKey: $cidKey');
//     return snapshot.docs.map((doc) {
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       return Member(data: data);
//     }).toList();
//   }
//
//   // Get Member data from snapshots
//   Member _memberFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     return Member(data: data);
//   }
//
//   //Get Member stream
//   Stream<List<Member>> get memberList {
//     if (cidKey != null) {
//       return memberCollection.snapshots()
//           .map(_memberListFromSnapshot);
//     } else {
//       log('Database: Something went wrong for get memberList, cidKey: $cidKey uid: $uid');
//       return const Stream.empty();
//     }
//   }
//
// //   // Get Member doc stream
// //   Stream<Member> get member {
// //
// //     if (cid != null) {
// //       return memberCollection.doc(pid).snapshots()
// //           .map((DocumentSnapshot doc) => _memberFromSnapshot(doc));
// // //    .map(_playerFromSnapshot);
// //     } else {
// //       log('Database: Something went wrong for get member, cid: $cid pid: $pid');
// //       return const Stream.empty();
// //     }
// //   }
//
// // =============================================================================
// //                ***   MEMBERSHIP DATABASE MEMBERS   ***
// // =============================================================================
//   // Todo: change parameters to required named parameters.
//   // Update Membership
//   Future<void> addMembership({required Membership membership}) async {
//
//     int noMemberships = -1;
//     log('Adding Membership : $uid / ${membership.key}');
//     await membershipCollection.doc(membership.key).set(membership.updateMap);
//     await membershipCollection.count().get().then((res) => noMemberships = res.count,);
//     await playerCollection.doc(uid).update(
//         {"noMemberships": noMemberships});
//   }
//
//   Future<void> updateMembership({required Membership membership }) async {
//     return await membershipCollection.doc(membership.key).set({ membership.updateMap });
//   }
//
//   // Delete given the Collection ID
//   Future<void> deleteMembership(String midKey) async {
//     int noMemberships = -1;
//
//     await membershipCollection.doc(midKey).delete();
//     await membershipCollection.count().get().then((res) =>
//         noMemberships = res.count,
//       );
//     await playerCollection.doc(uid).update(
//         {"noMemberships": noMemberships});
//   }
//
//   // Member list from snapshot
//   List<Membership> _membershipListFromSnapshot(QuerySnapshot snapshot) {
//     log('Database: _m..fromSnapshot: Membership Size is ${snapshot.size} UID: $uid');
//     return snapshot.docs.map((doc) {
//       Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
//       return Membership(data: data);
//     }).toList();
//   }
//
//   // Get Member data from snapshots
//   Membership _membershipFromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
//     return Membership(data: data);
//   }
//
//   //Get Member stream
//   Stream<List<Membership>> get membershipList {
//     return membershipCollection.snapshots()
//         .map(_membershipListFromSnapshot);
//   }
}