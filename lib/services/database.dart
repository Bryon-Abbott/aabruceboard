//import 'package:aaflutterfirebase/models/brew.dart';
import 'dart:developer';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/game.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  String pid;
  String? sid;
  String? gid;
  final CollectionReference playerCollection = FirebaseFirestore.instance.collection('Player');
  late CollectionReference seriesCollection;
  late CollectionReference gameCollection;
  late CollectionReference boardCollection;

  DatabaseService({ required this.pid, this.sid, this.gid })
  {
    seriesCollection = playerCollection.doc(pid).collection('Series');
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
    return await playerCollection.doc(pid).set({
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
        uid: pid,
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
      uid: pid,
      fName: data['fName'],
      lName: data['lName'],
      initials: data['initials']
    );
  }

  //get players stream
  // ToDo: refactor players to playerList;
  Stream<List<Player>> get playerList {
    return playerCollection.snapshots()
      .map(_playerListFromSnapshot);
  }

  // get player doc stream
  Stream<Player> get player {
    return playerCollection.doc(pid).snapshots()
    .map((DocumentSnapshot doc) => _playerFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }

// =============================================================================
//                ***   SERIES DATABASE MEMBERS   ***
// =============================================================================
  // Todo: change parameters to required named parameters.
  // Update Series
  Future<DocumentReference> addSeries({
    required String name,
    required String type}) async {

    return await seriesCollection.add({
      'name': name,
      'type': type,
    });
  }

  Future<void> updateSeries({
    required String sid,
    required String name,
    required String type}) async {

    return await seriesCollection.doc(sid).set({
      'name': name,
      'type': type,
    });
  }

  // Player list from snapshot
  List<Series> _seriesListFromSnapshot(QuerySnapshot snapshot) {
    //seriesCollection = playerCollection.doc(uid).collection('Series');
    log('Series Size is ${snapshot.size} UID: $pid');
    return snapshot.docs.map((doc) {
      //print(doc.data);
      Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Series(
        sid: doc.id,
        name: data['name'] ?? 'NAME',
        type: data['type'] ?? 'TYPE',
      );
    }).toList();
  }

  // Series data from snapshots
  Series _seriesFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    return Series(
      sid: snapshot.id,
      name: data['name'],
      type: data['type'],
    );
  }

  //get collections stream
  Stream<List<Series>> get seriesList {
    return seriesCollection.snapshots()
        .map(_seriesListFromSnapshot);
  }

  // get player doc stream
  Stream<Series> get series {

    return seriesCollection.doc(pid).snapshots()
        .map((DocumentSnapshot doc) => _seriesFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }
// =============================================================================
//                ***   GAME DATABASE MEMBERS   ***
// =============================================================================
  // Update Game
  Future<DocumentReference> addGame(
      {required String sid, required String pid,
        required String name,
        required String teamOne,
        required String teamTwo,
        required int squareValue,
      }) async
  {
    return await gameCollection.add({
      'sid' : sid,
      'pid' : pid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    });
  }

  Future<void> updateGame(
      { required String gid, required String sid, required String pid,
        required String name,
        required String teamOne,
        required String teamTwo,
        required int squareValue,
      }) async {

    return await gameCollection.doc(gid).set({
      'sid' : sid,
      'pid' : pid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    });
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
    log("Getting board for GID: $gid, PID: $pid, SID: $sid");
    return boardCollection.doc(gid).snapshots()
        .map((DocumentSnapshot doc) => _boardFromSnapshot(doc));
//    .map(_playerFromSnapshot);
  }
}