import 'dart:developer' as dev;
import 'dart:math';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
//import 'package:bruceboard/utils/preferences.dart';
import 'package:intl/intl.dart';

enum SquareStatus {free, requested, taken}

class Grid implements FirestoreDoc {
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextBid';
  @override
  final String totalField = 'noBoards';

  final NumberFormat _keyFormat = NumberFormat("G00000000", "en_US");
  String gid='none';

  int sid = -1;
//  String uid = 'error' ;
  List<int> squarePlayer;     // Player PID
  List<int> squareCommunity;  // Community where Player Member record resides
  List<int> squareStatus;     // Free,Requested,Taken
  List<String> squareInitials;// Player Initials
  List<int> rowScores;
  List<int> colScores;
//  bool scoresLocked = false;
//  Board({ required this.gid, }) :
  Grid({ required Map<String, dynamic> data, }) :
    docId = data['docId']                                   ?? -1,
    squarePlayer = data['squarePlayer']?.cast<int>()        ?? List<int>.filled(100, -1),       // 100
    squareCommunity = data['squareCommunity']?.cast<int>()  ?? List<int>.filled(100, -1),  // 100
    squareStatus = data['squareStatus']?.cast<int>()        ?? List<int>.filled(100, SquareStatus.free.index),
    squareInitials = data['squareInitials']?.cast<String>() ?? List<String>.filled(100, 'FS'),  // 100
    rowScores = data['rowScores']?.cast<int>()              ?? List<int>.filled(10, -1),        // 10
    colScores = data['colScores']?.cast<int>()              ?? List<int>.filled(10, -1)        // 10
//    scoresLocked = data['scoresLocked']                     ?? false
  ;

  // Return the number of squares FREE (not PICKED or EXCLUDED)
  int getFreeSquares() {
    int free = squarePlayer.where((e) => e == -1).length;
    dev.log("Number of free squares is $free", name: "${runtimeType.toString()}:getFreeSquares");
    return free;
  }

  // Return the number of squares SELECTED (INcluding excluded squares)
  int getSelectedSquares() {
    int picked = squarePlayer.where((e) => e != -1).length;
    dev.log("Number of picked squares is $picked", name: "${runtimeType.toString()}:getPickedSquares");
    return picked;
  }

  // Return the number of squares PICKED (EXcluding excluded squares)
  int getPickedSquares() {
    // String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ??
    //     "-1";  // If no perferences saved for ExcludePlayerNo, default to -1
    // int excludePlayerNo = int.parse(excludePlayerNoString);

    int picked = squarePlayer.where((e) => (e != -1) && (e != kExcludePlayerNo)).length;
    //dev.log("Number of bought squares is $picked", name: "${runtimeType.toString()}:getBoughtSquares");
    return picked;
  }

  // Set the values of the score cells for the x and y axes
  void setScores() {

    List<int> scores = [0,1,2,3,4,5,6,7,8,9];

    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      rowScores[i] = scores.removeAt(pick);
    }
    scores = [0,1,2,3,4,5,6,7,8,9];
    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      colScores[i] = scores.removeAt(pick);
    }
  //  scoresLocked = true;
  }

  bool get scoresLocked {
    return ((colScores[0] != -1) && (rowScores[0] != -1));
  }

  @override
  String get key {
    String key = _keyFormat.format(docId);
    return key;
  }

  @override
  void update({required Map<String, dynamic> data}) {
    docId = data['docId'] ?? docId;
    squarePlayer = data['squarePlayer'];      // 100
    squareCommunity = data['squareCommunity'];      // 100
    squareInitials = data['squareInitials'];  // 100
    squareStatus = data['squareStatus'];
    rowScores = data['rowScores'];            // 10
    colScores = data['colScores'];            // 10
//    scoresLocked = data['scoresLocked'];

  }

  @override
  // TODO: implement updateMap
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'squarePlayer' : squarePlayer,
      'squareCommunity' : squareCommunity,
      'squareInitials' : squareInitials,
      'squareStatus' : squareStatus,
      'scoresLocked' : scoresLocked,
      'rowScores' : rowScores,
      'colScores' : colScores,
    };
  }
}

