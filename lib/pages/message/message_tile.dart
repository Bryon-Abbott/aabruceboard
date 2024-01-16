import 'dart:developer';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/message.dart';
import 'package:provider/provider.dart';
// Todo: Complete reject for Community Add
class MessageTile extends StatelessWidget {
  final Message message;
  const MessageTile({ super.key,  required this.message });

  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            log("Message Tapped ... ${message.docId} ");
          },
          leading: const Icon(Icons.message_outlined),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message: ${messageDesc[message.messageType]}'),
              Text('>: ${message.description}'),
              Text('>: ${message.comment}'),
            ],
          ),
          subtitle:
            Text('${message.key}:${message.timestamp.toDate()}:${message.messageType.toString().padLeft(5, '0')}'),
          trailing: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 80,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => messageAccept(context),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                  IconButton(
                    onPressed: (message.responseCode == messageResp[messageRespType.request])
                        ? () => messageReject(context)
                        : null,
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ==========================================================================
  // Switch to run when Player selects "ACCEPT" on card
  // ==========================================================================
  Future<void> messageAccept (BuildContext context) async {
    Player playerFrom = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidFrom) as Player;
    Player playerTo = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidTo) as Player;
    log('message_tile: messageAccept: Type: ${message.messageType} From: ${playerFrom.fName} To: ${playerTo.fName}');
    switch (message.messageType) {
    // ========================================================================
    // ------------------------------------------------------------------------
    // *** Message Processing
    // *** Comment Message
      case 00000: {   // Comment
        log("Pressed Message Accept - Comment");
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Add Request Message
    // 1. Get community data
    // 2. Add Player Member to Community
    // 3. Send Accept message
      case 00001: {   // Community Add Request Message
        Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
        // Add Member to Community
        Member member = Member(data:
          { 'docId': message.pidFrom,   // Set the memberID to the pid of the sending player
            'credits': 0,
          });
        String? comment = await openDialogMessageComment(context, defaultComment: "Welcom to the community <${community.name}>");
        if (comment != null) {
          await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocAdd(member);
          // Add Message to Archive
          String desc = '${playerTo.fName} ${playerTo.lName} accepted your request to be added to the <${community.name}> community';
          await messageMembershipAddAcceptResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
              comment: comment, description: desc);
        } else {
          log('Case 00001: Cancelled accepting Add to Community.', name: '${runtimeType.toString()}:messageAccept');
        }
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Remove Request Message
    // 1. Get community data
    // 2. Add Player Member to Community
    // 3. Send Accept message
      case 00002: {   // Community Remove Request Message
        log('message_tile: case 00002:');
        FirestoreDoc? result = await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid']))
            .fsDoc(docId: message.pidFrom);
        log('message_tile: case 00002: member: ${result?.docId ?? 'No member'}');
        if (result == null) {
        // Member? member = await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid']))
        //   .fsDoc(docId: message.pidFrom) as Member;
        // if (member == null) {  // Didn't find the member in the community? Maybe not registered yet.
          Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
          String? comment = await openDialogMessageComment(context, defaultComment:"Were not registered to our community" );
          // Add Message to Archive
          if (comment != null ) {
            String desc = '${playerTo.fName} ${playerTo.lName} accepted your request to be removed from the <${community.name ?? "No Name"}> community';
            await messageMembershipRemoveAcceptResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
                comment: comment, description: desc);
          }
        } else {
          Member member = result as Member;
          if (member.credits == 0)  {
            Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
            String? comment = await openDialogMessageComment(context, defaultComment: "Sorry to see you leave our community");
            if (comment != null ) {
              await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocDelete(member);
              // Add Message to Archive
              String desc = '${playerTo.fName} ${playerTo.lName} accepted your request to be removed from the <${community.name}> community';
              await messageMembershipRemoveAcceptResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
                  comment: comment, description: desc);
            }
          } else {
            // Error: Member has credits ... display message
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Member has ${member.credits} credit(s) remaining, zero out before removing member"))
            );
          }
        }
      }
      break;
    // ------------------------------------------------------------------------
    // *** Square Request Message
      case 00003: {
        String? comment = "Good luck ${playerFrom.fName}";
        String desc = "No Message";
        int squareRequested = message.data['squareRequested'];
        log('Case 00003:', name: '${runtimeType.toString()}:messageAccept');

        Game? game = await DatabaseService(FSDocType.game, sidKey: Series.Key(message.data['sid']))
            .fsDoc(docId: message.data['gid']) as Game;
        log('case 00003: square value: ${game.squareValue}', name: '${runtimeType.toString()}:messageAccept');

        Grid? grid = await DatabaseService(FSDocType.grid, sidKey: Series.Key(message.data['sid']), gidKey: game.key)
            .fsDoc(docId: message.data['gid']) as Grid;
        log("case 00003: grid player: ${grid.squarePlayer}, '${grid.squareInitials}' ", name: '${runtimeType.toString()}:messageAccept');

        Member? member = await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid']))
            .fsDoc(docId: message.pidFrom) as Member;
        log('Case 00003: Credits: ${member.credits}', name: '${runtimeType.toString()}:messageAccept');

        if (member.credits >= game.squareValue) {  // Member has enough
          if (grid.squarePlayer[squareRequested] == -1) {  // Square is open
            comment = await openDialogMessageComment(context, defaultComment: comment);
            if ( comment != null ) {
              member.credits -= game.squareValue;
              grid.squarePlayer[squareRequested] = playerFrom.docId;
              grid.squareInitials[squareRequested] = playerFrom.initials;
              grid.squareCommunity[squareRequested] = message.data['cid'];
              // Todo: Look at the need for awaits here
              await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocUpdate(member);
              await DatabaseService(FSDocType.grid, sidKey: Series.Key(message.data['sid']), gidKey: game.key).fsDocUpdate(grid);
              await DatabaseService(FSDocType.board, sidKey: Series.Key(message.data['sid']), gidKey: game.key)
                  .fsDocUpdateField(key: game.key, field: 'squaresPicked', ivalue: grid.getPickedSquares());
              messageSquareSelectAcceptResponse(
                  data: message.data,
                  message: message,
                  playerFrom: playerFrom,
                  playerTo: playerTo,
                  comment: comment ?? "No Comment",
                  description: '${playerTo.fName} ${playerTo.lName} accepted your request for Square $squareRequested from Game <${game.name}>'
              );
            } else {
              log("Case 00003: Message Accept Cancelled", name: '${runtimeType.toString()}:messageAccept');
            }
          } else {
            log("Case 00003: Square $squareRequested is taken. '${grid.squareInitials[squareRequested]}:${grid.squarePlayer[squareRequested]}'", name: '${runtimeType.toString()}:messageAccept');
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Square $squareRequested is taken. '${grid.squareInitials[squareRequested]}:${grid.squarePlayer[squareRequested]}'"),
                )
            );
          }
        } else {
          log("Case 00003: Not enough Credits: ${member.credits} for square value ${game.squareValue}", name: '${runtimeType.toString()}:messageAccept');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Not enough Credits: ${member.credits} for square value ${game.squareValue}"),
              )
          );
        }
      }
      break;
    // ------------------------------------------------------------------------
    // *** Credits Request Message
    // 1. Get Member data
    // 2. Update Credits (+/-)
    // 3. Send Accept message
      case 00004: {   // Membership Credit Request Message
        log('message_tile: case 00004:');
        int credits = message.data['credits'];
        Member? member = await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid']))
            .fsDoc(docId: message.pidFrom) as Member;
        log('message_tile: case 00004: member: ${member.docId ?? 'No Member'}');
        //
        String? comment = await openDialogMessageComment(context, defaultComment: "Credits ($credits) were updated to your membership\n (New Balance: ${member.credits+credits})");
        // Add Message to Archive
        if (comment != null) {
          // Update Credits and save to database.
          if (message.data['creditDebit'] == 'credit') {
            member.credits += message.data['credits'] as int;
          } else {
            member.credits -= message.data['credits'] as int;
          }
          await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocUpdate(member);
          // Send Message back to Requester
          Community? community = await DatabaseService(FSDocType.community).fsDoc(docId: message.data['cid']) as Community;
            String desc = '${playerTo.fName} ${playerTo.lName} accepted your request to add/refund credits '
                '(Credits:${message.data['credits']} Balance:${member.credits} ) '
                'to your membership in the <${community.name ?? "No Name"}> community';
            await messageMembershipCreditsAcceptResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
                comment: comment, description: desc);
        }
      }
      break;
    // ========================================================================
    // Response Messages
    // ------------------------------------------------------------------------
    // *** Community Add *ACCEPT* Response Message
    // 1. Update Membership to "Approved"
    // 2. Add message to Archive  (Processed)
    // 3. Delete active message
      case 10001: {
        log('message_tile: Community Add Response from: ${playerFrom.fName} to: ${playerTo.fName}');
        // Update Community Add Request to Approved / Rejected
        // Todo: Should not be updating MembermessageMembershipCreditsAcceptResponseship in Message System?
        Membership membership = Membership(data:
        { 'docId': message.data['msid'],  // Membership ID of Requester
          'cid': message.data['cid'],     // Community ID
          'cpid': message.data['cpid'],     // PID of Community
          'pid': message.data['pid'],     // PID of Player
        });
        // Todo: Should not be updating Membership in Message System.
        if (message.responseCode == messageResp[messageRespType.accepted]) {
          membership.status = 'Approved' ;
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        } else if (message.responseCode == messageResp[messageRespType.rejected]) {
          // Update membership with Status back to Approved if Removal was rejected
          membership.status = 'Rejected' ;
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        }
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Remove Response Message
    // 1. Update Membership to "Rejected"
    // 2. Add message to Archive  (Processed)
    // 3. Delete active message
      case 10002: {
        log('message_tile: Community Add Response from: ${playerFrom.fName} to: ${playerTo.fName}');
        Membership membership = Membership(data:
        { 'docId': message.data['msid'],
          'cid': message.data['cid'],
          'cpid': message.data['cpid'],
          'pid': message.data['pid'],

          'status': "Approved",
        });
        if (message.responseCode == messageResp[messageRespType.accepted]) {
          await DatabaseService(FSDocType.membership).fsDocDelete(membership);
        } else if (message.responseCode == messageResp[messageRespType.rejected]) {
          // Update membership with Status back to Approved if Removal was rejected
          membership.status = 'Approved';
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        }
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Square Request Response Message
      case 10003: {
        log('10003: Square Request Accept Response from: ${playerFrom.fName} to: ${playerTo.fName}', name: "${runtimeType.toString()}:messageAccept()");
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Square Request Response Message
      case 10004: {
        log('10004: Credit Request Accept/Reject Response from: ${playerFrom.fName} to: ${playerTo.fName}', name: "${runtimeType.toString()}:messageAccept()");
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20001: {
        log('message_tile: Add Member Notification from: ${playerFrom.fName} to: ${playerTo.fName}');
        Membership membership = Membership(data:
        { // 'docId': message.data['msid'],  // No docId so use membershipNextNo.
          'cid': message.data['cid'],     // Community ID
          'cpid': playerFrom.pid,   // PID of Community
          'pid': playerTo.pid, // PID of Player
          'status': 'Approved',
        });
        await DatabaseService(FSDocType.membership).fsDocAdd(membership);
        // Archive the message
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20002: {
        log('message_tile: Edit Member Notification from: ${playerFrom.fName} to: ${playerTo.fName}');
        await messageArchive(message: message, playerFrom: playerFrom);
      }
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20003: {
        log('message_tile: Remove Member Notification from: ${playerFrom.fName} to: ${playerTo.fName}');
        Membership membership = Membership(data:
        { // 'docId': message.data['msid'],  // No docId so use membershipNextNo.
          'cid': message.data['cid'],     // Community ID
          'cpid': playerFrom.pid,   // PID of Community
          'pid': playerTo.pid, // PID of Player
          'status': 'Removed',
        });
        await DatabaseService(FSDocType.membership).fsDocAdd(membership);
        // Archive Message
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20004: {
        log('message_tile: Remove Credit Request Notification from: ${playerFrom.fName} to: ${playerTo.fName}');
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20005: {
        log('Square assiged from : ${playerFrom.fName} to: ${playerTo.fName}', name: "${runtimeType.toString()}:messageAccept()");
        await messageArchive(message: message, playerFrom: playerFrom);
      }
      break;
      default:
        log('message_tile: Error ... invalid Message Type ${message.messageType}');
    }
  }
  // ==========================================================================
  // Switch to run when Player selects "REJECT" on card
  // ==========================================================================
  void messageReject (BuildContext context) async {
    log('message_tile: reject');
    Player playerFrom = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidFrom) as Player;
    Player playerTo = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidTo) as Player;
    switch (message.messageType) {
    // ========================================================================
    // ------------------------------------------------------------------------
      case 00000: {   // Comment
        log("Pressed Message Reject - Comment");
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Add Reject Response Message
      case 00001: {   // Community Add Request Message
        log("Pressed Message Reject - Community Add");
        Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
        // Add Message to Archive
        String? comment = await openDialogMessageComment(context) ?? "Sorry your request has been rejected";
        String desc = '${playerTo.fName} ${playerTo.lName} rejected your request to be added to the <${community.name}> community';
        await messageMembershipAddRejectResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
        comment: comment, description: desc);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Remove Reject Response Message
      case 00002: {   // Community Remove Request Message
        log("Pressed Message Reject - Community Remove");
        Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
        // Add Message to Archive
        String? comment = await openDialogMessageComment(context, defaultComment: "Sorry your request has been rejected");
        if (comment  != null) {
          String desc = '${playerTo.fName} ${playerTo.lName} rejected your request to be removed from the <${community.name}> community';
          await messageMembershipRemoveRejectResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
              comment: comment, description: desc);
        }
      }
      break;
    // ------------------------------------------------------------------------
    // *** Credit Request Reject Response Message
      case 00003: {
      int squareRequested = message.data['squareRequested'];
      log('Case 00003:', name: '${runtimeType.toString()}:messageAccept');

      Game? game = await DatabaseService(FSDocType.game, sidKey: Series.Key(message.data['sid']))
          .fsDoc(docId: message.data['gid']) as Game;
      log('case 00003: square value: ${game.squareValue}', name: '${runtimeType.toString()}:messageAccept');

      String? comment = "Sorry, rejected ${playerFrom.fName}";
      String desc = "No Message";

      comment = await openDialogMessageComment(context, defaultComment: comment);
      if ( comment != null ) {
        messageSquareSelectRejectResponse(
            data: message.data, message: message,
            playerFrom: playerFrom, playerTo: playerTo, comment: comment,
            description: '${playerTo.fName} ${playerTo.lName} rejected your request for Square $squareRequested from Game <${game.name}>'
        );
      } else {
        log("Case 00003: Message Reject Cancelled", name: '${runtimeType.toString()}:messageAccept');
      }
    }
    break;
    // ------------------------------------------------------------------------
    // *** Credit Request Reject Response Message
      case 00004: {
        log("Pressed Message Reject - Credit Request");
        Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
        // Add Message to Archive
        String? comment = await openDialogMessageComment(context, defaultComment: "Sorry your request has been rejected");
        if ( comment != null ) {
          String desc = '${playerTo.fName} ${playerTo.lName} rejected your request to adjust your credits for the <${community.name}> community';
          await messageMembershipCreditsRejectResponse(message: message, playerFrom: playerFrom, playerTo: playerTo,
              comment: comment, description: desc);
        }
      }
      break;
    // ========================================================================
    // Todo: Clean up these invalid responses (disable / remove reject icon)
    // ------------------------------------------------------------------------
      case 10001: {   // Community Add Request Accept Respnose Message
        log('message_tile: Pressed Message Reject - Community Add Accept Response');
        log("message_tile: *** Cant Reject a Response message");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't Reject a Response message, accept"),
            )
        );
      }
      break;
    // ------------------------------------------------------------------------
      case 10002: {   // Community Remove Request Message
        log('message_tile: Pressed Message Reject - Community Remove Reject Response');
        log("message_tile: *** Cant Reject a Response message");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't Reject a Response message, accept"),
            )
        );
      }
      break;
    // ------------------------------------------------------------------------
      case 20001: {   // Community Remove Request Message
        log('message_tile: Pressed Message Reject - Add Credits Notification');
        log("message_tile: *** Cant Reject a Notification message");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't Reject a Response message, accept"),
            )
        );
      }
      break;
    // ------------------------------------------------------------------------
      case 20002: {   // Community Remove Request Message
        log('message_tile: Pressed Message Reject - Remove Membership Notification');
        log("message_tile: *** Cant Reject a Notification message");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't Reject a Response message, accept"),
            )
        );
      }
      break;
    // ------------------------------------------------------------------------
      case 20004: {   // Community Remove Request Message
        log('message_tile: Pressed Message Reject - Credit Request Notification');
        log("message_tile: *** Cant Reject a Notification message");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Can't Reject a Response message, accept"),
            )
        );
      }
      break;
      default:
        log('message_tile: Error ... invalid Message Type ${message.messageType}');
    }
  }
}