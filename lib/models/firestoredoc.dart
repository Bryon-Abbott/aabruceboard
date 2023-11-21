// Firestore Document - BaseClass
import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:intl/intl.dart';

// enum ShapeType
enum FSDocType { series, community, game, member, membership, board, message, player }

abstract class FirestoreDoc {
  final String nextIdField = 'nextFsid';    // Stored in Player
  final String totalField = 'noDocuments';  // Strored in Parent
  int docId = -1;
  final NumberFormat _keyFormat = NumberFormat("FS00000000", "en_US");

  factory FirestoreDoc(FSDocType fsDocType, { required Map<String, dynamic> data, })
  {
      switch (fsDocType) {
        case FSDocType.player:
          return Player(data: data);
        case FSDocType.series:
          return Series(data: data);
        case FSDocType.community:
          return Community(data: data);
        case FSDocType.game:
          return Game(data: data);
        case FSDocType.board:
          return Board(data: data);
        default:
          log('Invalid Document Type');
          throw 'Invalid document type';
      }
    //docId = data['docId'] ?? -1;
  }

  String get key
  { // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving member $key");
    return key;
  }

  void update({ required Map<String, dynamic> data, }) {
    docId = data['fsid'] ?? docId;  // From Super
  }

  Map<String, dynamic> get updateMap {
    return { 'docId': docId, };
  }
}