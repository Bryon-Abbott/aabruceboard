
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';
enum Permission { private, public, }

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
  int sid; // Series ID
  int pid; // Player ID

  String name; // = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";
  String gameDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int status = 0; // Prep=0, Active=1; Complete=2; Archive=3;
  int permission = Permission.private.index;

  Game({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        sid = data['sid'] ?? -1,
        pid = data['pid'] ?? -1,
        name = data['name'] ?? 'NAME',
        teamOne = data['teamOne'] ?? 'ONE',
        teamTwo = data['teamTwo'] ?? 'TWO',
        gameDate = data['gameDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        squareValue = data['squareValue'] ?? 0,
        status = data['status'] ?? 0,
        permission = data['permission'] ?? Permission.private.index; // 0=Private, 1=Public, Default to Private.

  @override
  String get key {
    String key = _keyFormat.format(docId);
    return key;
  }

  static String Key(int gid) {
    String key = _keyFormat.format(gid);
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
    // gameDate = (data['gameDate'] != null) ? DateTime.parse(data['gameDate']) : gameDate;
    gameDate = data['gameDate'] ?? gameDate;
    squareValue = data['squareValue'] ?? squareValue;
    status = data['status'] ?? 0;
    permission = data['permission'] ?? Permission.private.index;
  }

  @override
  Map<String, dynamic> get updateMap {
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
      'permission' : permission,
    };
  }
}