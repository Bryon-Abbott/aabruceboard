import 'package:bruceboard/models/firestoredoc.dart';
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

//  int sid = -1;
  String uid = 'error' ;
  List<int> rowResults;   // = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> colResults;   //  = List<int>.filled(4, -1);    // Team1-Q1, Q2, Q3, Q4
  List<int> percentSplits;//  = List<int>.filled(5, 20); // Q1, Q2, Q3, Q4, Community
  int squaresPicked;      // =0;
  bool scoresLocked;
  bool creditsDistributed = false;

  bool dirty = true;

//  Board({ required this.gid, }) :
  Board({ required Map<String, dynamic> data, }) :
    docId = data['docId']                              ?? -1,
    rowResults = data['rowResults']?.cast<int>()       ?? List<int>.filled(4, -1),    // Team1-Q1, Q2, Q3, Q4
    colResults = data['colResults']?.cast<int>()       ?? List<int>.filled(4, -1),    // Team1-Q1, Q2, Q3, Q4
    percentSplits = data['percentSplits']?.cast<int>() ?? List<int>.filled(5, 20), // Q1, Q2, Q3, Q4, Community
    squaresPicked = data['squaresPicked']              ?? 0,
    scoresLocked = data['scoresLocked']                ?? false,
    creditsDistributed = data['creditsDistributed']    ?? false;

  @override
  String get key {
    String key = _keyFormat.format(docId);
    return key;
  }

  @override
  void update({required Map<String, dynamic> data}) {
    docId = data['docId'] ?? docId;
    rowResults = data['rowResults'];
    colResults = data['colResults'];
    percentSplits = data['percentSplits'];
    squaresPicked = data['squaresPicked'];  // From Grid
    scoresLocked = data['scoresLocked'];    // From Grid
    creditsDistributed = data['creditsDistributed'];
  }

  @override
  // TODO: implement updateMap
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'rowResults' : rowResults,
      'colResults' : colResults,
      'percentSplits' : percentSplits,
      'squaresPicked' : squaresPicked,
      'scoresLocked' : scoresLocked,
      'creditsDistributed' : creditsDistributed,
    };
  }
}
