import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Community extends FirestoreDoc {
  // Base Variables
  @override
  final String nextIdField = 'nextCid';
  @override
  final String totalField = 'noCommunities';
  @override
  final NumberFormat _keyFormat = NumberFormat("MS00000000", "en_US");
  // Data Class Variables
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
        noMembers = data['noMembers'] ?? 0,
        super(data: {'docID': data['docId'] ?? -1});

  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    cid = data['cid'] ?? cid;
    uid = data['uid'] ?? uid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    noMembers = data['noMembers'] ?? noMembers;
  }

  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'cid': cid,
      'uid': uid,
      'name': name,
      'type': type,
      'noMembers': noMembers,
    };
  }
}