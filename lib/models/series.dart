
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Series implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextSid';
  @override
  final String totalField = 'noSeries';
  @override
  final NumberFormat _keyFormat = NumberFormat("S0000", "en_US");
  // Data Class Variables

//  int sid;  // Numeric 0000-9999
  String name;
  String type;
  int noGames;

  Series({ required Map<String, dynamic> data, }) :
    docId = data['docId'] ?? -1,
//    sid = data['sid'] ?? -1,
    name = data['name'] ?? 'NAME',
    type = data['type'] ?? 'TYPE',
    noGames = data['noGames'] ?? 0;

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
//    sid = data['sid'] ?? sid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    noGames = data['noGames'] ?? noGames;
  }

  @override
  String get key {
    // Format Key for Document ID
    NumberFormat intFormat = NumberFormat("S0000", "en_US");
    String key = intFormat.format(docId);
    //log("Getting Series key $key");
    return key;
  }
  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
//      'sid': sid,
      'name': name,
      'type': type,
      'noGames': noGames,
    };
  }
}