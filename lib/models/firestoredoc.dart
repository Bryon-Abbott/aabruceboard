// Firestore Document - BaseClass
import 'dart:developer';
import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:intl/intl.dart';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';

// enum ShapeType
enum FSDocType {
  player,
    series, access, game, board, grid,
    community, member,
    membership,
    messageowner, message }

abstract class FirestoreDoc {
  final String nextIdField = 'nextFsid';    // Stored in Player
  final String totalField = 'noDocuments';  // Strored in Parent
  int docId = -1;
  static final NumberFormat _keyFormat = NumberFormat("FS00000000", "en_US");

  factory FirestoreDoc(FSDocType fsDocType, { required Map<String, dynamic> data, })
  {
      switch (fsDocType) {
        case FSDocType.player:
          return Player(data: data);
        case FSDocType.series:
          return Series(data: data);
        case FSDocType.access:
          return Access(data: data);
        case FSDocType.community:
          return Community(data: data);
        case FSDocType.game:
          return Game(data: data);
        case FSDocType.board:
          return Board(data: data);
        case FSDocType.grid:
          return Grid(data: data);
        case FSDocType.membership:
          return Membership(data: data);
        case FSDocType.member:
          return Member(data: data);
        case FSDocType.messageowner:
          return MessageOwner(data: data);
        case FSDocType.message:
          return Message(data: data);
        default:
          log('FirestoreDoc: Invalid Document Type');
          throw 'Invalid document type';
      }
    //docId = data['docId'] ?? -1;
  }

  static String KEY(int fsid) {
    String key = NumberFormat("FS00000000", "en_US").format(fsid);
    return key;
  }

  String get key
  { // Format Key for Document ID
    String key = _keyFormat.format(docId);
    log("Retrieving Firestoredoc $key", name: '${runtimeType.toString()}:key');
    return key;
  }

  void update({ required Map<String, dynamic> data, }) {
    docId = data['fsid'] ?? docId;  // From Super
  }

  Map<String, dynamic> get updateMap {
    return { 'docId': docId, };
  }
}