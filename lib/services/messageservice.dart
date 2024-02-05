import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
// Request --> Response.Acceptance --> Acknowledgment
// Request --> Response.Rejection --> Acknowledgment
// Notifiaction --> Acknowledgement
//
// Message Rules:
// Request Requires a Response                (00000 - 09999)
// Response is the result of a Request        (10000 - 19999)
// Notification is a one way message          (20000 - 29999)
// Acknowledgemnet to a Resp or Notification  (30000 - 39999)
// Query Requires a Query Response            (40000 - 49999)
// Query Response is the result of a Query Response (50000 - 59999)

const messageDesc = {
  00000: "Message",                   // Desc(General Message) (Response: Optional: Text Response)
// Requests
  00001: "Community Add Request",     // Data:{cid: }
  00002: "Community Remove Request",  // Desc(Request to be Removed from Community) Input(Community) Response(Required: Accept / Reject)
  00003: "Square Select Request",     // Desc(Request Square) Input(Board, Square), Response(Required: Accept/Reject)
  00004: "Credit Adjust Request",     // Desc(Request Credits) Input(Community, Amount, Debit/Credit), Response(Required: Accept/Reject)
// Responses
  10001: "Community Add Response",
  10002: "Community Remove Response",
  10003: "Square Request Response",
  10004: "Credit Adjust Response",
// Notifications
  20001: "Add Member Notification",                 // Data: {cid: }
  20002: "Edited Member Notification",
  20003: "Removed Member Notification",
  20004: "Remove Credit Notification",
  20005: "Assigned Square Notification",
  20006: "Accepted Square Request Notification",
  20007: "Credit Distribution Notification",
// Acknowledgement
  30001: "Add Member Acknowledgement",                    // Data: {cid: }
  30002: "Remove Member Acknowledgement",                 // Data: {credits: }
  30003: "Update Member Record Acknowledgement",          // Data: {credits: }
  30004: "Community Add Request Accept Acknowledgement",  // Data: {cid: }
  30005: "Community Add Request Reject Acknowledgement",  // Data: {cid: }
  30006: "Credit Adjust Acknowledgement, "
};

enum MessageTypeOption {
   undefined, acceptance, rejection, notification, acknowledgment, request
}
const Map<MessageTypeOption, int> messageType = {
  MessageTypeOption.undefined: -1,
  MessageTypeOption.rejection: 0,
  MessageTypeOption.acceptance: 1,
  MessageTypeOption.notification: 2,
  MessageTypeOption.acknowledgment: 3,
  MessageTypeOption.request: 4,
};

class MessageService {

}
// 
Future<void> messageSend(
    int messageCode,
    int messageType,
  { required playerFrom,
    required playerTo,
    int responseCode = -1,  // Undefined
    String description = 'No descriptions',
    String comment = 'Please add me to your community',
    Map<String, dynamic> data = const {},
  }) async {
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': playerFrom.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': playerFrom.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: playerTo.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message notification = Message(
      data:
        { 'messageCode' : messageCode,
          'messageType' : messageType,
          'pidFrom': playerFrom.pid,
          'pidTo': playerTo.pid,
          'description': description,
          'comment': comment,
          'data': data,
        });
  return await DatabaseService(FSDocType.message, toUid: playerTo.uid).fsDocAdd(notification);
}
// ********** ADD REQ:00001 / RESP:10001 **********
// ********** REMOVE REQ:00002 / RESP:10002 **********
// ==========================================================================
// ==========================================================================
// Send messages to notify Player that Credits have been added to there membership from a game distribution.
Future<void> messageMemberDistributedCreditsNotification(
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
  Message notification = Message(data:
  { 'messageCode' : 20007,  // 20002 Edit Member notification
    'messageType': messageType[MessageTypeOption.notification],      // Notification ... No response expected.
    'pidFrom': fromPlayer.pid,
    'pidTo': toPlayer.pid,
    'description': description,
    'comment': comment,
    'data': { 'credits': credits }
  });
  return await DatabaseService(FSDocType.message, toUid: toPlayer.uid).fsDocAdd(notification);
}
// ==========================================================================
// Send messages to notify Player that Credits have NOT been added to there membership.
// ==========================================================================
// Send messages to Community Player to request Credits .
Future<void> messageSquareAssignedNotification(
    { required cid,
      required sid,
      required gid,
      required squareRequested,
      required Player playerFrom,
      required Player playerTo,
      String description = 'Square Assigneed',
      String comment = 'Square has been assigned to you'}) async {
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': playerFrom.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': playerFrom.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: playerTo.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message message = Message(data:
  { 'messageCode' : 20005,  // 20005 Notify Square selected for user.
    'messageType': messageType[MessageTypeOption.notification],      // Notification ... No response expected.
    'pidFrom': playerFrom.pid,
    'pidTo': playerTo.pid,
    'description': description,
    'comment': comment,
    'data': { 'cid': cid, 'sid': sid, 'gid': gid, 'squareRequested': squareRequested },
  });
  return await DatabaseService(FSDocType.message, toUid: playerTo.uid).fsDocAdd(message);
}
// ==========================================================================
// Send messages to Community Player to request Credits .
Future<void> messageSquareSelectRequest(
    { required cid, // Community to Get Requesters Member Record & Credits
      required sid, // Series the Game is from
      required gid, // Game the Square is requested from
      required squareRequested, // Requested Square
      required Player playerFrom,
      required Player playerTo,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': playerFrom.pid,  // Current Players PID (ie Player the message was sent to)
    'uid': playerFrom.uid,  // Current Players UID
  });
  await DatabaseService(FSDocType.messageowner, toUid: playerTo.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message message = Message(data:
  { 'messageCode' : 00003,  // 00003 Square Request
    'messageType': messageType[MessageTypeOption.request],
    'pidFrom': playerFrom.pid,
    'pidTo': playerTo.pid,
    'description': description,
    'comment': comment,
    'data': { 'cid': cid, 'sid': sid, 'gid': gid, 'squareRequested': squareRequested },
  });
  return await DatabaseService(FSDocType.message, toUid: playerTo.uid).fsDocAdd(message);
}
// ==========================================================================
// Send messages to notify Player that Credits have been added to there membership.
Future<void> messageSquareSelectAcceptResponse(
    { required Map<String, dynamic> data,// { 'cid, sid, gid, squareRequested }
      required Message message,
      required Player playerFrom,
      required Player playerTo,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  // Archive Message from
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid).fsDocDelete(message);
  // Add MemberOwner to Repsonding Player (From)
  log('messageService: messageMembershipCreditsAcceptResponse: Creating MessageOwner From: ${playerFrom.pid} to ${playerTo.pid}');
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': playerTo.pid,  // Responding Players (Owner) PID (ie Player the message was sent to)
    'uid': playerTo.uid,    // Responding Players (Owner) UID (The player the original message was sent to)
  });
  await DatabaseService(FSDocType.messageowner, toUid: playerFrom.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  // Send response back TO the player the original message came FROM
  log('messageService: messageMembershipCreditsAcceptResponse: Creating Message From: ${playerFrom.pid} to ${playerTo.pid}');
  Message response = Message(data:
  { 'messageCode' : 10003,  // 10003 Add Credits response
    'messageType': messageType[MessageTypeOption.acceptance],
    'pidFrom': playerTo.pid,
    'pidTo': playerFrom.pid,
    'description': description,
    'comment': comment,
    'data': data,
  });
  // Send response to the user (toUid) the original request was from (playerFrom)
  return await DatabaseService(FSDocType.message, toUid: playerFrom.uid).fsDocAdd(response);
}
// ==========================================================================
// Send messages to notify Player that Credits have NOT been added to there membership.
// Steps:
Future<void> messageSquareSelectRejectResponse(
    { required Map<String, dynamic> data,   // { 'cid, gid, squareRequested }
      required Message message,
      required Player playerFrom,
      required Player playerTo,
      String description = 'No descriptions',
      String comment = 'Please add me to your community'}) async {
  // Archive Message
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid ).fsDocDelete(message);
  // Add MemberOwner to Community Player for current Player
  MessageOwner msgOwner = MessageOwner( data: {
    'docId': playerTo.pid,  // Responding Players (Owner) PID (ie Player the message was sent to)
    'uid': playerTo.uid,    // Responding Players (Owner) UID (The player the original message was sent to)
  });
  await DatabaseService(FSDocType.messageowner, toUid: playerFrom.uid).fsDocAdd(msgOwner);
  // Add Message (response) to senders messages.
  Message response = Message(data:
  { 'messageCode' : 10003,  // 10003 Add/Remove Credits response
    'messageType': messageType[MessageTypeOption.rejection],
    'pidFrom': playerTo.pid,
    'pidTo': playerFrom.pid,
    'description': description,
    'comment': comment,
    'data': data,
  });
  return await DatabaseService(FSDocType.message, toUid: playerFrom.uid).fsDocAdd(response);
}
// ==========================================================================
// Archive the provided message
Future<void> messageArchive({
    required Message message,
    required Player playerFrom}) async {
  // Add Message to Archive
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid, messageLocation: 'Processed').fsDocAdd(message);
  // Delete Message
  await DatabaseService(FSDocType.message, fromUid: playerFrom.uid).fsDocDelete(message);
}


