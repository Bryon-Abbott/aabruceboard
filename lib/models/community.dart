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

  static final NumberFormat _keyFormat = NumberFormat("C0000", "en_US");
  // Data Class Variables
  int pid;
  String name;
  String type;
  String charity;
  String charityNo;
  int noMembers=0;

  Community({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        pid = data['pid'] ?? -1,
        name = data['name'] ?? 'NAME',
        type = data['type'] ?? 'TYPE',
        charity = data['charity'] ?? '',
        charityNo = data['charityNo'] ?? '',
        noMembers = data['noMembers'] ?? 0;

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    pid = data['pid'] ?? pid;
    name = data['name'] ?? name;
    type = data['type'] ?? type;
    charity = data['charity'] ?? charity;
    charityNo = data['charityNo'] ?? charityNo;
    noMembers = data['noMembers'] ?? noMembers;
  }

  static String Key(int cid) {
    String key = _keyFormat.format(cid);
    return key;
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
      'pid': pid,
      'name': name,
      'type': type,
      'charity': charity,
      'charityNo': charityNo,
      'noMembers': noMembers,
    };
  }
}