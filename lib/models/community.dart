import 'dart:developer';
import 'package:intl/intl.dart';

class Community {
  int cid;
  String uid;
  String name;
  String type;
  int noMembers=0;

  Community({ required Map<String, dynamic> data, }) :
        cid = data['cid'] ?? -1,
        uid = data['uid'] ?? 'error',
        name = data['name'] ?? 'NAME',
        type = data['type'] ?? 'TYPE',
        noMembers = data['noMembers'] ?? 0;

  void update({ required Map<String, dynamic> data, }) {
    cid = data['cid'] ?? cid;
    uid = data['uid'] ?? uid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    noMembers = data['noMembers'] ?? noMembers;
  }

  String get key {
    // Format Key for Document ID
    NumberFormat intFormat = NumberFormat("C0000", "en_US");
    String key = intFormat.format(cid);
    // log("Retrieving community $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  Map<String, dynamic> get updateMap {
    return {
      'cid': cid,
      'uid': uid,
      'name': name,
      'type': type,
      'noMembers': noMembers,
    };
  }

}