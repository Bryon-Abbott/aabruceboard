import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/databaseservice.dart';

// ============================================================================
// Desc: Function to review and update all Communities with correct noMembers.
void updateCounts({required String collection}) async {
  int actualCount = 0, collectionCount = 0;
  List<FirestoreDoc> firestoreDocs = await DatabaseService(FSDocType.community).fsDocList;
  for (FirestoreDoc f in firestoreDocs) {
    Community c = f as Community;
    actualCount = await DatabaseService(FSDocType.member, cidKey: c.key).fsDocCount;
    if (actualCount != c.noMembers) {
      log("*** Community Member Missmatch ${c.docId} Name: ${c.name} NoMembers: ${c.noMembers} Actual Members ${actualCount}");
      c.noMembers = actualCount;
      await DatabaseService(FSDocType.community).fsDocUpdate(c);
    }
  }
  return;
}