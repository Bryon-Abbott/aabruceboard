
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Game extends FirestoreDoc {
  // Base Variables
  @override
  final String nextIdField = 'nextGid';
  @override
  final String totalField = 'noGames';
  @override
  final NumberFormat _keyFormat = NumberFormat("G00000000", "en_US");
  // Data Class Variables
  int gid; // Game ID
  int sid; // Series ID
  String uid; // Owners UID

  String name = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";

  Game({ required Map<String, dynamic> data, }) :
        gid = data['gid'] ?? -1,
        sid = data['sid'] ?? -1,
        uid = data['uid'] ?? 'error',
        name = data['name'] ?? 'NAME',
        teamOne = data['teamOne'] ?? 'ONE',
        teamTwo = data['teamTwo'] ?? 'TWO',
        squareValue = data['squareValue'] ?? 0,
        super(data: {'docID': data['docId'] ?? -1});

  @override
  void update({
    required Map<String, dynamic> data,
  }) {
    gid = data['gid'] ?? gid;
    sid = data['sid'] ?? sid;
    uid = data['uid'] ?? uid;
    name = data['name'] ?? name;
    teamOne = data['teamOne'] ?? teamOne;
    teamTwo = data['teamTwo'] ?? teamTwo;
    squareValue = data['squareValue'] ?? squareValue;
  }

  @override
  String get key {
    String key = _keyFormat.format(docId);
    // log("Gettign Game key $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'gid': gid,
      'sid': sid,
      'uid': uid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'squareValue': squareValue,
    };
  }
}