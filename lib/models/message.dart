// Community Member
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:bruceboard/models/firestoredoc.dart';

// Note Used
enum messageType {
  MS0000,     // Null Message
  MS0001      // Request to Join Community
}

class Message implements FirestoreDoc {
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextMeid';
  @override
  final String totalField = 'noMessages';
  @override
  final NumberFormat _keyFormat = NumberFormat("ME00000000", "en_US");
  // Document Specific Data items
  // @override
  // int docId;
  int pidFrom;  // /Player/{UID-REC}/Message/{UID-SEND}/Incoming/{MSID-KEY}
  int pidTo;
  String type;
  String userMessage;

  //Member({ required this.cid, required this.uid, required this.credits, });
  Message({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        pidFrom = data['pidFrom'] ?? -1,
        pidTo = data['pidTo'] ?? -1,
        type = data['type'] ?? 'MS0000',
        userMessage = data['userMessage'] ?? 'No user message provided';

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;  // From Super
    pidFrom = data['pidFrom'] ?? pidFrom;
    pidTo = data['pidTo'] ?? pidTo;
    type = data['type'] ?? type;
    userMessage = data['userMessage'] ?? userMessage;
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
  // type: MS0000 - Null / Invalid Message
  //       MS0001 - Community Join Request
  //       MS0002 - Square Request
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'pidFrom': pidFrom,
      'pidTo': pidTo,
      'type': type,
      'userMessage': userMessage,
    };
  }

}