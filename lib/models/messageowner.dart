// Community Member
import 'package:intl/intl.dart';
import 'package:bruceboard/models/firestoredoc.dart';


class MessageOwner implements FirestoreDoc {
  @override
  int docId = -1;  // Set to User PID
  @override
  final String nextIdField = 'nextMoid';
  @override
  final String totalField = 'noMessagesOwners';

  // final NumberFormat _keyFormat = NumberFormat("MO00000000", "en_US");
  // Document Specific Data items
  // @override
  // int docId;
  String uid;

  //Member({ required this.cid, required this.uid, required this.credits, });
  MessageOwner({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        uid = data['uid'] ?? 'error';

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;  // From Super
    uid = data['uid'] ?? 'error';
  }

  static String Key(int docId) {
    NumberFormat intFormat = NumberFormat("MS00000000", "en_US");
    String key = intFormat.format(docId);
    return key;
  }

  // The key should be UID for Message keys???
  @override
  String get key {
    return uid;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'uid': uid,
    };
  }
}