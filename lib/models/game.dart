
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

  static final NumberFormat _keyFormat = NumberFormat("G00000000", "en_US");
  // Data Class Variables
//  int gid; // Game ID
  int sid; // Series ID
  int pid; // Player ID
//  String uid; // Owners UID

  String name; // = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";
  // DateTime gameDate = DateTime.now();
  String gameDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int status = 0; // Prep=0, Active=1; Complete=2; Archive=3;

  Game({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        sid = data['sid'] ?? -1,
        pid = data['pid'] ?? -1,
        name = data['name'] ?? 'NAME',
        teamOne = data['teamOne'] ?? 'ONE',
        teamTwo = data['teamTwo'] ?? 'TWO',
        gameDate = data['gameDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        squareValue = data['squareValue'] ?? 0,
        status = data['status'] ?? 0;

  @override
  String get key {
    String key = _keyFormat.format(docId);
    // log("Gettign Game key $key");
    return key;
  }

  static String Key(int gid) {
    String key = _keyFormat.format(gid);
    return key;
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    // DateTime defaultDate = DateTime.now();
    // DateFormat('yyyy-MM-dd').format(defaultDate);
    docId = data['docId'] ?? docId;
    sid = data['sid'] ?? sid;
    pid = data['uid'] ?? pid;
    name = data['name'] ?? name;
    teamOne = data['teamOne'] ?? teamOne;
    teamTwo = data['teamTwo'] ?? teamTwo;
    // gameDate = (data['gameDate'] != null) ? DateTime.parse(data['gameDate']) : gameDate;
    gameDate = data['gameDate'] ?? gameDate;
    squareValue = data['squareValue'] ?? squareValue;
    status = data['status'] ?? 0;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    // String gameDateString;
    // gameDateString = DateFormat('yyyy-MM-dd').format(gameDate);
    return {
      'docId': docId,
      'sid': sid,
      'pid': pid,
      'name': name,
      'teamOne': teamOne,
      'teamTwo': teamTwo,
      'gameDate': gameDate,
      'squareValue': squareValue,
      'status' : status,
    };
  }
}