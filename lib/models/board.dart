import 'dart:developer' as dev;
import 'dart:math';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:intl/intl.dart';

class Board implements FirestoreDoc {
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextBid';
  @override
  final String totalField = 'noBoards';
  @override
  final NumberFormat _keyFormat = NumberFormat("G00000000", "en_US");
  String gid='none';

  int sid = -1;
  String uid = 'error' ;
  List<int> boardData = List<int>.filled(100, -1);
  List<int> rowScores = List<int>.filled(10, -1);
  List<int> colScores = List<int>.filled(10, -1);
  List<int> rowResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> colResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> percentSplits = List<int>.filled(5, 20); // Q1, Q2, Q3, Q4, Community
  bool dirty = true;

//  Board({ required this.gid, }) :
  Board({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? -1;
  }

  bool scoresLocked = false;

  int getFreeSquares() {
    int free = boardData.where((e) => e == -1).length;
    dev.log("Number of free squares is $free", name: "${runtimeType.toString()}:getFreeSquares");
    return free;
  }

  int getPickedSquares() {
    int picked = boardData.where((e) => e != -1).length;
    dev.log("Number of picked squares is $picked", name: "${runtimeType.toString()}:getPickedSquares");
    return picked;
  }

  int getBoughtSquares() {
    String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ??
        "-1";  // If no perferences saved for ExcludePlayerNo, default to -1
    int excludePlayerNo = int.parse(excludePlayerNoString);

    int picked = boardData.where((e) => (e != -1) && (e != excludePlayerNo)).length;
    dev.log("Number of bought squares is $picked", name: "${runtimeType.toString()}:getBoughtSquares");
    return picked;
  }

  // Set the values of the score cells for the x and y axes
  void setScores() {
    List<int> scores = [];

    scores = [0,1,2,3,4,5,6,7,8,9];
    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      rowScores[i] = scores.removeAt(pick);
    }
    scores = [0,1,2,3,4,5,6,7,8,9];
    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      colScores[i] = scores.removeAt(pick);
    }
    scoresLocked = true;
  }

  @override
  String get key {
    String key = _keyFormat.format(docId);
    return key;
  }

  @override
  void update({required Map<String, dynamic> data}) {
    docId = data['docId'] ?? docId;
    boardData = data['boardData'];
    rowScores = data['rowScores'];
    colScores = data['colScores'];
    rowResults = data['rowResults'];
    colResults = data['colResults'];
    percentSplits = data['percentSplits'];
  }

  @override
  // TODO: implement updateMap
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'boardData' : boardData,
      'rowScores' : rowScores,
      'colScores' : colScores,
      'rowResults' : rowResults,
      'colResults' : colResults,
      'percentSplits' : percentSplits,
    };
  }
}

