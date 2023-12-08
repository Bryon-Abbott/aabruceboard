import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';

const messageDesc = {
  00000: "Message",                   // Desc(General Message) (Respnose: Optional: Text Response)
// Requests
  00001: "Community Add Request",     // Desc(Request to Add Community) Input(Community) Response(Required: Accept / Reject)
  00002: "Community Remove Request",  // Desc(Request to be Removed from Community) Input(Community) Response(Required: Accept / Reject)
  00003: "Square Select Request",     // Desc(Request Square) Input(Board, Square), Response(Required: Accept/Reject)
  00004: "Credit Request",            // Desc(Request Credits) Input(Community, Amount), Response(Required: Accept/Reject)
// Responses
  10001: "Community Add Response",
  10002: "Community Remove Response",
  10003: "Square Select Response",
// Notifications
  20001: "Added Credits Notification",  //
};

enum messageRespType {
   undefined, accepted, rejected, notification,
}
const messageResp = {
  messageRespType.undefined: -1,
  messageRespType.rejected: 0,
  messageRespType.accepted: 1,
  messageRespType.notification: 2,
};

class MessageService {

}
// ********** ADD REQ:00001 / RESP:10001 **********
// ==========================================================================
// Send messages to request to *ADD* to a Community
// Steps:
// 1. Create Message Owner for Player on Community Players message queue
// 2. Create Message requesting to Add on Community Player message queue
Future<void> messageMembershipAddRequest( {
    required Membership membership,
    required Player player,
    required Player communityPlayer,
    String description = 'No descriptions',
    String comment = 'Please add me to your community'} ) async {

  log("membership_list: messageMembershipRequest: ${membership.docId ?? -500}");
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': player.docId,
    'uid': player.uid,  // Sending Players UID
  } );
  await DatabaseService(FSDocType.messageowner, toUid: communityPlayer.uid).fsDocAdd(msgOwner);
  // Add Add Request Message to Community Player with "Requested" Status
  Message msg = Message( data: {
    'messageType': 00001, // Community Add Request
    'pidTo': communityPlayer.docId,
    'pidFrom': player.docId,
//    'uid': communityPlayer.uid,  // Sending Players UID
    'data': {
      'msid': membership.docId,  // Membership ID of requesting player
      'pid': membership.pid,     // Community Player ID
      'cid': membership.cid,     // Community ID of Community Player
    },
    'description': description,
    'comment': comment,
  } );
  log('membership_lsit: Adding Message to ${communityPlayer.uid} from U: ${player.uid}');
  return await DatabaseService(FSDocType.message, toUid: communityPlayer.uid).fsDocAdd(msg);
}
// ==========================================================================
// Send messages to request to be added to Community
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageMembershipAddAcceptResponse(
    {  required Message message,
      required Player fromPlayer,
      required Player toPlayer,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid ).fsDocDelete(message);
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': toPlayer.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': toPlayer.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: fromPlayer.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message response = Message(data:
  { 'messageType' : 10001,  // 10001,  // 10001=Community Add Response
    'pidFrom': message.pidTo,
    'pidTo': message.pidFrom,
    'responseCode': messageResp[messageRespType.accepted],      // *Accept*
    'description': description,
    'comment': comment,
    'data': { 'pid': message.data['pid'], 'cid': message.data['cid'], 'msid': message.data['msid']}
  });
  return await DatabaseService(FSDocType.message, toUid: fromPlayer.uid).fsDocAdd(response);
}
// ==========================================================================
// Send messages to request to be added to Community
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageMembershipAddRejectResponse(
    {  required Message message,
      required Player fromPlayer,
      required Player toPlayer,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid ).fsDocDelete(message);
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': toPlayer.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': toPlayer.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: fromPlayer.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message response = Message(data:
  { 'messageType' : 10001,  // 10002,  // 10002=Community Add Response
    'pidFrom': message.pidTo,
    'pidTo': message.pidFrom,
    'responseCode': messageResp[messageRespType.rejected],      // Rejected
    'description': description,
    'comment': comment,
    'data': {'cid': message.data['cid'], 'pid': message.data['pid']}
  });
  return await DatabaseService(FSDocType.message, toUid: fromPlayer.uid).fsDocAdd(response);
}
// ********** REMOVE REQ:00002 / RESP:10002 **********
// ==========================================================================
// Send messages to request to be *REMOVED* from Community
// Steps:
// 1. Create Message Owner for Player on Community Players message queue
// 2. Create Message requesting to join on Community Player message queue
Future<void> messageMembershipRemoveRequest( {
    required Membership membership,
    required Player player,
    required Player communityPlayer,
    String description = 'No descriptions',
    String comment = 'Please add me to your community'} ) async {

  // // Add MemberOwner to Community Player for current Player
  // Player? player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': player.docId,
    'uid': player.uid,  // Sending Players UID
  } );
  await DatabaseService(FSDocType.messageowner, toUid: communityPlayer.uid).fsDocAdd(msgOwner);
  // Add Join Request Message to Community Player with "Requested" Status
  Message msg = Message( data: {
    'messageType': 00002, // Community Remove Request
    'pidTo': communityPlayer.docId,
    'pidFrom': player.docId,
    'data': {
      'msid': membership.docId,  // Membership ID of requesting player
      'pid': membership.pid,     // Community Player ID
      'cid': membership.cid,     // Community ID of Community Player
    },
    'description': description,
    'comment': comment,
  } );
  log('membership_lsit: Adding Message to ${communityPlayer.uid} from U: ${player.uid}');
  return await DatabaseService(FSDocType.message, toUid: communityPlayer.uid).fsDocAdd(msg);
}
// ==========================================================================
// Send messages to request to be added to Community
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageMembershipRemoveAcceptResponse(
    {  required Message message,
      required Player fromPlayer,
      required Player toPlayer,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid ).fsDocDelete(message);
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': toPlayer.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': toPlayer.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: fromPlayer.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message response = Message(data:
  { 'messageType' : 10002,  // 10001,  // 10001=Community Remove Response
    'pidFrom': message.pidTo,
    'pidTo': message.pidFrom,
    'responseCode': messageResp[messageRespType.accepted],      // *Accepted*
    'description': description,
    'comment': comment,
    'data': { 'pid': message.data['pid'], 'cid': message.data['cid'], 'msid': message.data['msid']}
  });
  return await DatabaseService(FSDocType.message, toUid: fromPlayer.uid).fsDocAdd(response);
}
// ==========================================================================
// Send messages to request to be added to Community
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageMembershipRemoveRejectResponse(
    {  required Message message,
      required Player fromPlayer,
      required Player toPlayer,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid ).fsDocDelete(message);
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': toPlayer.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': toPlayer.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: fromPlayer.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message response = Message(data:
  { 'messageType' : 10002,  // 10002,  // 10002=Community Remove Response
    'pidFrom': message.pidTo,
    'pidTo': message.pidFrom,
    'responseCode': messageResp[messageRespType.rejected],      // Rejected
    'description': description,
    'comment': comment,
    'data': {'cid': message.data['cid'], 'pid': message.data['pid']}
  });
  return await DatabaseService(FSDocType.message, toUid: fromPlayer.uid).fsDocAdd(response);
}
// ==========================================================================
// Send messages to notify Player that Credits have been added to there membership.
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageMemberAddCreditsNotification(
    {  required int credits,
      required Player fromPlayer,
      required Player toPlayer,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': fromPlayer.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': fromPlayer.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: toPlayer.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message message = Message(data:
  { 'messageType' : 20001,  // 20001 Add Credits notification
    'pidFrom': fromPlayer.pid,
    'pidTo': toPlayer.pid,
    'responseCode': messageResp[messageRespType.notification],      // Notification ... No response expected.
    'description': description,
    'comment': comment,
    'data': { 'credits': 10 }
  });
  return await DatabaseService(FSDocType.message, toUid: toPlayer.uid).fsDocAdd(message);
}
// ==========================================================================
// Just archive the provided message
// Steps:
// 1. Create Copy of Message to 'Processed' message queue
// 2. Delete Message
// 3. Create Respnose message (and MessageOwner)
Future<void> messageArchive({
    required Message message,
    required Player fromPlayer}) async {
  // Add Message to Archive
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid).fsDocDelete(message);
}


