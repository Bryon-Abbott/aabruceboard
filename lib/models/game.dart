import 'dart:developer';

import 'package:intl/intl.dart';

class Game {
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
        squareValue = data['squareValue'] ?? 0;

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

  String get key {
    // Format Key for Document ID
    NumberFormat intFormat = NumberFormat("G00000000", "en_US");
    String key = intFormat.format(gid);
    // log("Gettign Game key $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
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

  // // Getters & Setters
  // set teamOne(String team) => _teamOne=team;
  // String get teamOne => _teamOne;
  // set teamTwo(String team) => _teamTwo=team;
  // String get teamTwo => _teamTwo;
  // set squareValue(int val) => _squareValue=val;
  // int get squareValue => _squareValue;

}