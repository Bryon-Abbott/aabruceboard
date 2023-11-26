import 'dart:developer';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/message.dart';
import 'package:provider/provider.dart';
//import 'package:bruceboard/pages/message/message_maintain.dart';

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
          title: Text('Message No: ${message.docId} : ${messageType[message.messageType]}'),
          subtitle: Text('Comment: ${message.userMessage} '),
          trailing: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 80,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () { messageAccept( bruceUser );  },
                      icon: const Icon(Icons.check_circle_outline),
                  ),
                  IconButton(
                    onPressed: () { messageReject( bruceUser ); },
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

 Future<void> messageAccept (BruceUser bruceUser) async {
    log('message_tile: accept ${message.messageType}');
    switch (message.messageType) {
    // =======================================================================
    // *** Message Processing
    // *** Comment Message
      case 0: {   // Comment
        log("Pressed Message Accept - Comment");
      }
      break;
      // --------------------------------------------------------------------
      // *** Community Join Request Message
      case 1: {   // Community Join Request Message
        log("message_tile: Pressed Message Accept - Community Join");
        Player fromPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidFrom) as Player;
        Player toPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: message.pidTo) as Player;
        // Add Member to Community
        Member member = Member(data:
          { 'docId': message.pidFrom,   // Set the memberID to the pid of the sending player
            'credits': 0,
          });
        log("message_tile: Adding Member for P: ${message.pidFrom} to C: ${message.data['cid']}");
        await DatabaseService(FSDocType.member, cidKey: Community.Key(message.data['cid'])).fsDocAdd(member);
        // Add Message to Archive
        log("message_tile: Archiving Message from P: ${message.pidFrom} ");
        await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid, messageLocation: 'Processed').fsDocAdd(message);
        // Delete Message
        log("message_tile: Deleting Message from P: ${message.pidFrom} ");
        await DatabaseService(FSDocType.message, fromUid: fromPlayer.uid ).fsDocDelete(message);
        // Add MemberOwner to Community Player for current Player
        MessageOwner msgOwner = MessageOwner( data: {
          'docId': toPlayer.pid,  // Current Players PID (ie Player the message was sent to)
          'uid': toPlayer.uid,  // Current Players UID
        } );
        log("message_tile: Adding MessageOwner from sender UID: ${fromPlayer.uid} ");
        await DatabaseService(FSDocType.messageowner, toUid: fromPlayer.uid).fsDocAdd(msgOwner);
        // Add Message (response) to senders messages.
        Message response = Message(data:
          { 'messageType' : 10001,  // 10001=Community Join Response
            'pidFrom': message.pidTo,
            'pidTo': message.pidFrom,
            'respnoseCode': 1,      // 1=Approved
            'data': {'cid': message.data['cid'], 'pid': message.data['pid']}
          });
        log("message_tile: Adding Message Response from sender UID: ${fromPlayer.uid} ");
        await DatabaseService(FSDocType.message, toUid: fromPlayer.uid).fsDocAdd(response);
      }
      break;
      // =======================================================================
      // *** Response Processing
      case 10001: {
        // Update Community Join Request to Approved / Rejected
        Membership membership = Membership(data:
        { 'cid': message.data['cid'],
          'pid': message.data['pid'],
          'status': "Approved",
        });
        // Todo: Fix this for responsing to responses from other users
        ???
        await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
        // Add Message to Archive
        await DatabaseService(FSDocType.message, messageLocation: 'Processed').fsDocAdd(message);
        // Delete Message
        await DatabaseService(FSDocType.message).fsDocDelete(message);
      }
      break;
      default:
        log('message_tile: Error ... invalid Message Type ${message.messageType}');
    }
  }

  void messageReject (BruceUser bruceUser) {
    log('message_tile: reject');
    switch (message.messageType) {
      case 0: {   // Comment
        log("Pressed Message Reject - Comment");
      }
      break;
      case 1: {   // Community Join Request Message
        log("Pressed Message Reject - Community Join");
      }
      break;
    }
  }
}