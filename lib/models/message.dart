// Community Member
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:bruceboard/models/firestoredoc.dart';

class Message implements FirestoreDoc {
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextMeid';
  @override
  final String totalField = 'noMembers';
  @override
  final NumberFormat _keyFormat = NumberFormat("ME00000000", "en_US");
  // Document Specific Data items
  // @override
  // int docId;
  int pidFrom;  // /Player/{UID-REC}/Message/{UID-SEND}/Incoming/{MSID-KEY}
  int pidTo;
  String type;

  //Member({ required this.cid, required this.uid, required this.credits, });
  Message({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        pidFrom = data['pidFrom'] ?? -1,
        pidTo = data['pidTo'] ?? -1,
        type = data['type'] ?? 'M000';

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;  // From Super
    pidFrom = data['pidFrom'] ?? pidFrom;
    pidTo = data['pidTo'] ?? pidTo;
    type = data['type'] ?? type;
  }

  // static String KEY(int id) {
  //   NumberFormat intFormat = NumberFormat("MS00000000", "en_US");
  //   String key = intFormat.format(id);
  //   return key;
  // }

  // The key should be UID for Message keys???
  @override
  String get key {
    // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving member $key");
    return key;
  }

  // Returns a Map<String, dynamic> of all member veriables.
  // type: MS00000000 - Null / Invalid Message
  //       MS00000001 - Community Join Request
  //       MS00000002 - Square Request
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'pidFrom': pidFrom,
      'pidTo': pidTo,
      'type': type,
    };
  }

}