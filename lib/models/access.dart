import 'package:bruceboard/models/firestoredoc.dart';
import 'package:intl/intl.dart';

class Access implements FirestoreDoc {
  // Base Variables
  @override
  int docId = -1;
  @override
  final String nextIdField = 'nextAid';
  @override
  final String totalField = 'noAccesses';
  // Data Class Variables
  int cid;  // Community ID
  int pid;  // Community Owner PID
  int sid;  // Series to which access is given.
//  String uid;
  String type;

  static final NumberFormat _cFormat = NumberFormat("C0000", "en_US");
  static final NumberFormat _pFormat = NumberFormat("P00000000", "en_US");

  Access({ required Map<String, dynamic> data, }) :
        docId = data['docId'] ?? -1,
        sid = data['sid'] ?? -1,
        cid = data['cid'] ?? -1,
        pid = data['pid'] ?? -1,
        type = data['type'] ?? 'error';

  // No override as Access takes 2 parameters.
  static String KEY(int pid, int cid) {
    // Format Key for Document ID
    String cKey = _cFormat.format(cid);
    String pKey = _pFormat.format(pid);
    // log("Membership: KEY: Retrieving community $pKey$cKey",  name: 'Access:KEY()');
    return "$pKey$cKey";
  }

  @override
  String get key {
    // Format Key for Document ID
    NumberFormat cFormat = NumberFormat("C0000", "en_US");
    String cKey = cFormat.format(cid);
    NumberFormat pFormat = NumberFormat("P00000000", "en_US");
    String pKey = pFormat.format(pid);
    // log("Retrieving community $pKey$cKey", name: "${runtimeType.toString()}:key");
    return "$pKey$cKey";
  }

  @override
  void update({ required Map<String, dynamic> data, }) {
    docId = data['docId'] ?? docId;
    sid = data['sid'] ?? -1;
    cid = data['cid'] ?? -1;
    pid = data['pid'] ?? -1;
    type = data['type'] ?? 'error';
  }

  // Returns a Map<String, dynamic> of all member veriables.
  @override
  Map<String, dynamic> get updateMap {
    return {
      'docId': docId,
      'sid': sid,
      'cid': cid,
      'pid': pid,
      'type': type,
    };
  }
}