import 'dart:developer' as dev;
import 'dart:math';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/utils/preferences.dart';

class Board extends FirestoreDoc {
  String gid='none';

  List<int> boardData = List<int>.filled(100, -1);
  List<int> rowScores = List<int>.filled(10, -1);
  List<int> colScores = List<int>.filled(10, -1);
  List<int> rowResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> colResults = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> percentSplits = List<int>.filled(5, 20); // Q1, Q2, Q3, Q4, Community
  bool dirty = true;

//  Board({ required this.gid, }) :
  Board({ required Map<String, dynamic> data, }) :
  super(data: {'docID': data['docId'] ?? -1});

  // @override
  // void dispose() {
  //   if (dirty) {
  //     dev.log("Save Board to Firebase");
  //   } else {
  //     dev.log("Dont Save Board to Firebase");
  //   }
  // }

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
    dev.log("Number of picked squares is $picked", name: "${runtimeType.toString()}:getPickedSquares");
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
}

