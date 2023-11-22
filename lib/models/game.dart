
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Game implements FirestoreDoc {
  // Base Variable
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextGid';
  @override
  final String totalField = 'noGames';
  @override
  final NumberFormat _keyFormat = NumberFormat("G00000000", "en_US");
  // Data Class Variables
//  int gid; // Game ID
  int sid; // Series ID
  int pid; // Player ID
//  String uid; // Owners UID

  String name = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";

  Game({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        sid = data['sid'] ?? -1,
        pid = data['pid'] ?? -1,
        name = data['name'] ?? 'NAME',
        teamOne = data['teamOne'] ?? 'ONE',
        teamTwo = data['teamTwo'] ?? 'TWO',
        squareValue = data['squareValue'] ?? 0;

  @override
  String get key {
    String key = _keyFormat.format(docId);
    // log("Gettign Game key $key");
    return key;
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    sid = data['sid'] ?? sid;
    pid = data['uid'] ?? pid;
    name = data['name'] ?? name;
    teamOne = data['teamOne'] ?? teamOne;
    teamTwo = data['teamTwo'] ?? teamTwo;
    squareValue = data['squareValue'] ?? squareValue;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'sid': sid,
      'pid': pid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    };
  }
}