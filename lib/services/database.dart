//import 'package:aaflutterfirebase/models/brew.dart';
import 'dart:developer';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/game.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  String uid;   // Current Active User ID
  String? sid;  // Series ID
  String? gid;  // Game ID (User as Game ID and Board ID)
  String? cid;  // Player ID (Used as Member)

  final CollectionReference playerCollection = FirebaseFirestore.instance.collection('Player');
  late CollectionReference seriesCollection;
  late CollectionReference communityCollection;
  late CollectionReference memberCollection;
  late CollectionReference gameCollection;
  late CollectionReference boardCollection;

  DatabaseService({ required this.uid, this.cid, this.sid, this.gid })
  {
    seriesCollection = playerCollection.doc(uid).collection('Series');
    communityCollection = playerCollection.doc(uid).collection('Community');

    if (cid != null) {
      memberCollection = communityCollection.doc(uid).collection('Member');
    }
    if (sid != null) {
      gameCollection = seriesCollection.doc(sid).collection('Game');
    }
    if (gid != null) {
      boardCollection = gameCollection.doc(gid).collection('Board');
    }
  }

// =============================================================================
//               ***   PLAYER DATABASE MEMBERS   ***
// =============================================================================

  // Update Player
  Future<void> updatePlayer(String fName, String lName, String initials) async {
    return await playerCollection.doc(uid).set({
      'fName': fName,
      'lName': lName,
      'initials': initials,
    });
  }

  // Player list from snapshot
  List<Player> _playerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Player(
        uid: uid,
        fName: data['fName'] ?? 'FNAME',
        lName: data['lName'] ?? 'LNAME',
        initials: data['initials'] ?? 'FN',
      );
    }).toList();
  }

  // Player data from snapshots
  Player _playerFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Player(
      uid: uid,
      fName: data['fName'],
      lName: data['lName'],
      initials: data['initials']
    );
  }

  //get players stream
  // ToDo: refactor players to playerList;
  Stream<List<Player>> get playerListStream {
    return playerCollection.snapshots()
      .map(_playerListFromSnapshot);
  }

  // get player doc stream
  Stream<Player> get playerStream {
    return playerCollection.doc(uid).snapshots()
    .map((DocumentSnapshot doc) => _playerFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }
  // get player doc stream
  Player? get player {
    playerCollection.doc(uid).get()
    .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Player(
        uid: doc.id,
        fName: data['fName'] ?? "Error",
        lName: data['lName'] ?? "Error",
        initials: data['initials'] ?? "Er",
      );
    },
    onError: (error) {
      log("Error getting Player UID: $uid, Error: $error");
      return null;
    });
  }

// =============================================================================
//                ***   SERIES DATABASE MEMBERS   ***
// =============================================================================
  // Todo: change parameters to required named parameters.
  // Update Series
  Future<DocumentReference> addSeries({
    required String name,
    required String type,
    required int noGames,
  }) async {

    return await seriesCollection.add({
      'name': name,
      'type': type,
      'noGames' : noGames,
    });
  }

  Future<void> updateSeries({
    required String sid,
    required String name,
    required String type,
    required int noGames }) async {

    return await seriesCollection.doc(sid).set({
      'name': name,
      'type': type,
      'noGames': noGames,
    });
  }
  // Update single field in Series doc
  Future<void> updateSeriesField({
    required String field,
    String? svalue,
    int? ivalue,
  }) async {

    if (sid != null) {
      return await seriesCollection.doc(sid).update({
        field: svalue ?? ivalue,
      });
    } else {
      log('Database: Something went wrong for field update $field uid: $uid, sid: $sid');
      // Todo: Throw an error here?
      return;
    }
  }
  Future<void> incrementSeriesNoGames(int val) async {

    if (sid != null) {
      return await seriesCollection.doc(sid).update(
          {"noGames": FieldValue.increment(val)});
    } else {
      log('DatabaseService: incrementSeriesNoGames missing Series ID');
    }
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> deleteSeries(String sid) async {
    return await seriesCollection.doc(sid).delete();
  }


  // Series list from snapshot
  List<Series> _seriesListFromSnapshot(QuerySnapshot snapshot) {
    //seriesCollection = playerCollection.doc(uid).collection('Series');
    log('Series Size is ${snapshot.size} UID: $uid');
    return snapshot.docs.map((doc) {
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

      Series series = Series(
        sid: doc.id,
        name: data['name'] ?? 'NAME',
        type: data['type'] ?? 'TYPE',
        noGames: data['noGames'] ?? 0,
//        noGames: data['noGames'].cast<int>() ?? 0,
      );
      return series;
    }).toList();
  }

  // Get Series data from snapshots
  Series _seriesFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Series(
      sid: snapshot.id,
      name: data['name'],
      type: data['type'],
      noGames: data['noGames'],
    );
  }

  //get collections stream
  Stream<List<Series>> get seriesList {
    return seriesCollection.snapshots()
        .map(_seriesListFromSnapshot);
  }

//   // get player doc stream
//   Stream<Series> get seriesStream {
//
//     return seriesCollection.doc(uid).snapshots()
//         .map((DocumentSnapshot doc) => _seriesFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//   }
// =============================================================================
//                ***   GAME DATABASE MEMBERS   ***
// =============================================================================
  // Update Game
  Future<DocumentReference> addGame(
      {required String sid, required String uid,
        required String name,
        required String teamOne,
        required String teamTwo,
        required int squareValue,
      }) async
  {
    return await gameCollection.add({
      'sid' : sid,
      'pid' : uid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    });
  }

  Future<void> updateGame(
      { required String gid, required String sid, required String uid,
        required String name,
        required String teamOne,
        required String teamTwo,
        required int squareValue,
      }) async {

    return await gameCollection.doc(gid).set({
      'sid' : sid,
      'pid' : uid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    });
  }

  // Delete given Game
  // Note: Application is responsible to delete the associated Board prior to this call!!
  Future<void> deleteGame(String gid) async {
    if (sid != null ) {
      return await gameCollection.doc(gid).delete();
    } else {
      log('DatabaseService: deleteGame missing Series ID');
    }
  }

  // Game list from snapshot
  List<Game> _gameListFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.docs.map((doc) {
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Game(
        gid: doc.id,
        sid: data['sid'] ?? 'error',
        pid: data['pid'] ?? 'error',
        name: data['name'] ?? 'error',
        teamOne: data['teamOne'] ?? 'error',
        teamTwo: data['teamTwo'] ?? 'error',
        squareValue: data['squareValue'] ?? -1,
      );
    }).toList();
  }

  // Game data from snapshots
  Game _gameFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Game(
      gid: snapshot.id,
      sid: data['sid'] ?? 'error',
      pid: data['pid'] ?? 'error',
      name: data['name'] ?? 'NAME',
      teamOne: data['teamOne'] ?? 'error',
      teamTwo: data['teamTwo'] ?? 'error',
      squareValue: data['squareValue'] ?? -1,
    );
  }

  //get collections stream
  Stream<List<Game>> get gameList {
    return gameCollection.snapshots()
        .map(_gameListFromSnapshot);
  }

  // get game doc stream
  Stream<Game> get game {

    return gameCollection.doc(sid).snapshots()
        .map((DocumentSnapshot doc) => _gameFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }
// =============================================================================
//                ***   BOARD DATABASE MEMBERS   ***
// =============================================================================
  // Update Board
  // Note form Board, the Board  ID (bid) is equal to the Game ID so the
  // 'add'member function uses the 'set' command using the gid as the unique number.
  Future<void> addBoard({
    required String gid,
        }) async {

    // Defaults for new board
    List<int> boardData = List<int>.filled(100, -1);
    List<int> rowScores = List<int>.filled(10, -1);
    List<int> colScores = List<int>.filled(10, -1);
    List<int> rowResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
    List<int> colResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
    List<int> percentSplits = List<int>.filled(5, 20); // Q1, Q2, Q3, Q4, Community

    return await boardCollection.doc(gid).set({
      'gid' : sid,
      'boardData'     : boardData,
      'rowScores'     : rowScores,
      'colScores'     : colScores,
      'rowResults'    : rowResults,
      'colResults'    : colResults,
      'percentSplits' : percentSplits,
    });
  }

  Future<void> updateBoard({
    required String field,
    required String value,
        }) async {

    if (gid != null) {
      return await boardCollection.doc(gid).set({
        field: value,
      });
    } else {
      // Todo: Throw an error here?
      return;
    }
  }

  // Delete given Board
  Future<void> deleteBoard() async {
    if (gid != null ) {
      return await boardCollection.doc(gid).delete();
    } else {
      log('DatabaseService: deleteGame missing Game ID');
    }
  }

  // Game list from snapshot
  List<Board> _boardListFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.docs.map((doc) {
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Board(
        gid: doc.id,
      );
    }).toList();
  }

  // Game data from snapshots
  Board _boardFromSnapshot(DocumentSnapshot snapshot) {

    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;

    Board board = Board(
      gid: data['gid'] ?? 'error',
    );

    board.boardData = data['boardData'].cast<int>();
    board.rowScores = data['rowScores'].cast<int>();
    board.rowResults = data['rowResults'].cast<int>();
    board.colScores = data['colScores'].cast<int>();
    board.rowResults = data['rowResults'].cast<int>();
    board.percentSplits = data['percentSplits'].cast<int>();
    board.dirty = false;

    return board;
  }

  //get collections stream
  Stream<List<Board>> get boardList {

    if (gid != null) {
      return boardCollection.snapshots()
          .map(_boardListFromSnapshot);
    } else {
      return Stream.empty();
    }
  }

  // get game doc stream
  Stream<Board> get board {
    log("Getting board for GID: $gid, UID: $uid, SID: $sid");
    return boardCollection.doc(gid).snapshots()
        .map((DocumentSnapshot doc) => _boardFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }

// =============================================================================
//                ***   COMMUNITY DATABASE MEMBERS   ***
// =============================================================================
  // Todo: change parameters to required named parameters.
  // Update Series
  Future<DocumentReference> addCommunity({
    required String name,
    required String approvalType,
    required int noMembers,
  }) async {

    return await communityCollection.add({
      'pid' : uid,   // Owner
      'name': name,
      'type': approvalType,
      'noMembers' : noMembers,
    });
  }

  Future<void> updateCommunity({
    required String cid,
    required String name,
    required String approvalType,
    required int noMembers }) async {

    return await communityCollection.doc(cid).set({
      'pid' : uid,
      'name': name,
      'approvalType': approvalType,
      'noMembers': noMembers,
    });
  }
  // Update single field in Series doc
  Future<void> updateCommunityField({
    required String cid,
    required String field,
    String? svalue,
    int? ivalue,
  }) async {

    return await communityCollection.doc(cid).update({
      field: svalue ?? ivalue,
    });
  }

  // increment / decriment Number of Members
  Future<void> incrementCommunityNoMembers(int val) async {

    return await communityCollection.doc(cid).update(
        {"noMembers": FieldValue.increment(val)});
  }

  // Delete given Series
  // Note: Application is responsible to delete Games prior to this call!!
  Future<void> deleteCommunity(String cid) async {
    return await communityCollection.doc(cid).delete();
  }


  // Series list from snapshot
  List<Community> _communityListFromSnapshot(QuerySnapshot snapshot) {
    log('Community Size is ${snapshot.size} UID: $uid');
    return snapshot.docs.map((doc) {
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

      Community community = Community(
        cid: doc.id,
        pid: data['pid'] ?? 'PID',
        name: data['name'] ?? 'NAME',
        approvalType: data['type'] ?? 'TYPE',
        noMembers: data['noMembers'] ?? 0,
      );
      return community;
    }).toList();
  }

  // Get Series data from snapshots
  Community _communityFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Community(
      cid: snapshot.id,
      pid: data['pid'] ?? 'PID',
      name: data['name'] ?? 'NAME',
      approvalType: data['type'] ?? 'TYPE',
      noMembers: data['noMembers'] ?? 0,
    );
  }

  //get collections stream
  Stream<List<Community>> get communityList {
    return communityCollection.snapshots()
        .map(_communityListFromSnapshot);
  }

  // get player doc stream
  Stream<Community> get community {

    if (cid != null) {
      return communityCollection.doc(cid).snapshots()
          .map((DocumentSnapshot doc) => _communityFromSnapshot(doc));
//    .map(_playerFromSnapshot);
    } else {
      log('Database: Something went wrong for get community, cid: $cid');
      // Todo: Throw an error here?
      return const Stream.empty();
    }
  }
// =============================================================================
//                ***   MEMBER DATABASE MEMBERS   ***
// =============================================================================
  // Todo: change parameters to required named parameters.
  // Update Series
  Future<void> addMember({
    required String pid,
    required int credits,
  }) async {

    if (cid != null) {
      return await memberCollection.doc(pid).set({
        'credits': credits,
      });
    } else {
      log('Database: Something went wrong for addMember, cid: $cid pid: $pid');
      return;
    }
  }

  Future<void> updateMember({
   required int credits }) async {

    return await memberCollection.doc(cid).set({
      'credits': credits,
    });
  }

  // increment / decriment Number of Members (Note MID = PID)
  Future<void> incrementMemberCredits({required String pid, required int val}) async {

    return await memberCollection.doc(pid).update(
        {"credits": FieldValue.increment(val)});
  }

  // Delete given the Player ID (which is the Document Reference for Members)
  // Note: Application should check to see if the Member is associate with any
  // active boards else this will be lost?
  Future<void> deleteMember(String pid) async {
    return await memberCollection.doc(pid).delete();
  }

  // Member list from snapshot
  List<Member> _memberListFromSnapshot(QuerySnapshot snapshot) {
    log('Member Size is ${snapshot.size} CID: $cid');
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

      Member community = Member(
        cid: doc.id,
        pid: data['pid'] ?? 'PID',
        credits: data['credits'] ?? 0,
      );
      return community;
    }).toList();
  }

  // Get Member data from snapshots
  Member _memberFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Member(
      cid: snapshot.id,
      pid: data['pid'] ?? 'PID',
      credits: data['noMembers'] ?? 0,
    );
  }

  //Get Member stream
  Stream<List<Member>> get memberList {
    if (cid != null) {
      return memberCollection.snapshots()
          .map(_memberListFromSnapshot);
    } else {
      log('Database: Something went wrong for get memberList, cid: $cid uid: $uid');
      return const Stream.empty();
    }
  }

//   // Get Member doc stream
//   Stream<Member> get member {
//
//     if (cid != null) {
//       return memberCollection.doc(pid).snapshots()
//           .map((DocumentSnapshot doc) => _memberFromSnapshot(doc));
// //    .map(_playerFromSnapshot);
//     } else {
//       log('Database: Something went wrong for get member, cid: $cid pid: $pid');
//       return const Stream.empty();
//     }
//   }

}