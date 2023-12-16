import 'dart:developer';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
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
                    onPressed: () => messageReject(context),
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
    log('message_tile: messageAccept: Type: ${message.messageType}');
    Player fromPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidFrom) as Player;
    Player toPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidTo) as Player;
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
        String? comment = await openDialogMessageComment(context) ?? "Welcome to the community";
        await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocAdd(member);
        // Add Message to Archive
        String desc = '${toPlayer.fName} ${toPlayer.lName} accepted your request to be added to the <${community.name}> community';
        await messageMembershipAddAcceptResponse(message: message, fromPlayer: fromPlayer, toPlayer: toPlayer,
        comment: comment, description: desc);
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
          String? comment = await openDialogMessageComment(context) ?? "Were not registered to our community";
          // Add Message to Archive
          String desc = '${toPlayer.fName} ${toPlayer.lName} accepted your request to be removed from the <${community.name ?? "No Name"}> community';
          await messageMembershipRemoveAcceptResponse(message: message, fromPlayer: fromPlayer, toPlayer: toPlayer,
              comment: comment, description: desc);
        } else {
          Member member = result as Member;
          if (member.credits == 0)  {
            Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
            String? comment = await openDialogMessageComment(context) ?? "Sorry to see you leave our community";
            await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocDelete(member);
            // Add Message to Archive
            String desc = '${toPlayer.fName} ${toPlayer.lName} accepted your request to be removed from the <${community.name}> community';
            await messageMembershipRemoveAcceptResponse(message: message, fromPlayer: fromPlayer, toPlayer: toPlayer,
                comment: comment, description: desc);
          } else {
            // Error: Member has credits ... display message
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Member has ${member.credits} credit(s) remaining, zero out before removing member"))
            );
          }
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
        log('message_tile: Community Add Response from: ${fromPlayer.fName} to: ${toPlayer.fName}');
        // Update Community Add Request to Approved / Rejected
        Membership membership = Membership(data:
        { 'docId': message.data['msid'],  // Membership ID of Requester
          'pid': message.data['pid'],     // PID of Community
          'cid': message.data['cid'],     // Community ID
//          'status': "Approved",
        });
        if (message.responseCode == messageResp[messageRespType.accepted]) {
          membership.status = 'Approved' ;
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        } else if (message.responseCode == messageResp[messageRespType.rejected]) {
          // Update membership with Status back to Approved if Removal was rejected
          membership.status = 'Rejected' ;
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        }
        await messageArchive(message: message, fromPlayer: fromPlayer);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Remove Response Message
    // 1. Update Membership to "Rejected"
    // 2. Add message to Archive  (Processed)
    // 3. Delete active message
      case 10002: {
        log('message_tile: Community Add Response from: ${fromPlayer.fName} to: ${toPlayer.fName}');
        Membership membership = Membership(data:
        { 'cid': message.data['cid'],
          'pid': message.data['pid'],
          'docId': message.data['msid'],
          'status': "Approved",
        });
        if (message.responseCode == messageResp[messageRespType.accepted]) {
          await DatabaseService(FSDocType.membership).fsDocDelete(membership);
        } else if (message.responseCode == messageResp[messageRespType.rejected]) {
          // Update membership with Status back to Approved if Removal was rejected
          membership.status = 'Approved';
          await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        }
        await messageArchive(message: message, fromPlayer: fromPlayer);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20001: {
        log('message_tile: Add Credits Notification from: ${fromPlayer.fName} to: ${toPlayer.fName}');
        await messageArchive(message: message, fromPlayer: fromPlayer);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Add Credits Notification Message
    // 1. No action - Archive Message
      case 20002: {
        log('message_tile: Remove Community Notification from: ${fromPlayer.fName} to: ${toPlayer.fName}');
        await messageArchive(message: message, fromPlayer: fromPlayer);
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
    Player fromPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidFrom) as Player;
    Player toPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidTo) as Player;
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
        String desc = '${toPlayer.fName} ${toPlayer.lName} rejected your request to be added to the <${community.name}> community';
        await messageMembershipAddRejectResponse(message: message, fromPlayer: fromPlayer, toPlayer: toPlayer,
        comment: comment, description: desc);
      }
      break;
    // ------------------------------------------------------------------------
    // *** Community Remove Reject Response Message
      case 00002: {   // Community Remove Request Message
        log("Pressed Message Reject - Community Remove");
        Community? community = await DatabaseService(FSDocType.community).fsDoc(key: Community.Key(message.data['cid'])) as Community;
        // Add Message to Archive
        String? comment = await openDialogMessageComment(context) ?? "Sorry your request has been rejected";
        String desc = '${toPlayer.fName} ${toPlayer.lName} rejected your request to be removed from the <${community.name}> community';
        await messageMembershipRemoveRejectResponse(message: message, fromPlayer: fromPlayer, toPlayer: toPlayer,
            comment: comment, description: desc);
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
              content: Text("Can't Reject a Response message, accpet"),
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
              content: Text("Can't Reject a Response message, accpet"),
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
              content: Text("Can't Reject a Response message, accpet"),
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
              content: Text("Can't Reject a Response message, accpet"),
            )
        );
      }
      break;
      default:
        log('message_tile: Error ... invalid Message Type ${message.messageType}');
    }
  }
}