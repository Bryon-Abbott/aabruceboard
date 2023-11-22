import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Community implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextCid';
  @override
  final String totalField = 'noCommunities';
  @override
  final NumberFormat _keyFormat = NumberFormat("C0000", "en_US");
  // Data Class Variables
  String uid;
  String name;
  String type;
  int noMembers=0;

  Community({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        uid = data['uid'] ?? 'error',
        name = data['name'] ?? 'NAME',
        type = data['type'] ?? 'TYPE',
        noMembers = data['noMembers'] ?? 0;

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    uid = data['uid'] ?? uid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    noMembers = data['noMembers'] ?? noMembers;
  }

  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'uid': uid,
      'name': name,
      'type': type,
      'noMembers': noMembers,
    };
  }
}