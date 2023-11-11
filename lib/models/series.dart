import 'dart:developer';

import 'package:intl/intl.dart';

class Series  {
  int sid=-1;  // Numeric 0000-9999
  String name;
  String type;
  int noGames;

  Series({ required Map<String, dynamic> data, }) :
    sid = data['sid'] ?? -1,
    name = data['name'] ?? 'NAME',
    type = data['type'] ?? 'TYPE',
    noGames = data['noGames'] ?? 0;

  void update({ required Map<String, dynamic> data, }) {
    sid = data['sid'] ?? sid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    noGames = data['noGames'] ?? noGames;
  }

  String get key {
    // Format Key for Document ID
    NumberFormat intFormat = NumberFormat("S0000", "en_US");
    String key = intFormat.format(sid);
    //log("Getting Series key $key");
    return key;
  }
  // Returns a Map<String, dynamic> of all member veriables.
  Map<String, dynamic> get updateMap {
    return {
      'sid': sid,
      'name': name,
      'type': type,
      'noGames': noGames,
    };
  }

}