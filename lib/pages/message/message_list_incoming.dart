import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/message/message_tile_incoming.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class MessageListIncoming extends StatefulWidget {
  const MessageListIncoming({super.key});

  @override
  State<MessageListIncoming> createState() => _MessageListIncomingState();
}

class _MessageListIncomingState extends State<MessageListIncoming> {

  late Player activePlayer;
  // late Message message;

  @override
  Widget build(BuildContext context) {

    activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    if (activePlayer.autoProcessAck) {
      autoProcess(messageTypeOption: MessageTypeOption.acknowledgment);
    }
    if (activePlayer.autoProcessAcc) {
      autoProcess(messageTypeOption: MessageTypeOption.acceptance);
    }
    if (activePlayer.autoProcessReq) {
      autoProcess(messageTypeOption: MessageTypeOption.request);
    }
    // Need to be more specific on Notifications as some result in
    // database updates (ie MemberAdd -> Memebership Document)
    // if (activePlayer.autoProcessNot) {
    //   autoProcess(messageTypeOption: MessageTypeOption.notification);
    // }

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.message, )
          .fsDocGroupListStream(group: "Incoming", pidTo: activePlayer.pid),   // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Message> message = snapshots.data!.map((a) => a as Message).toList();
          return Scaffold(
            appBar: AppBar(
                title: Text('Show Message - Count: ${message.length}'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: message.length,
              itemBuilder: (context, index) {
                return MessageTileIncoming(message: message[index]);
              },
            ),
          );
        } else {
          log("Incoming Message Snapshot has no data ... loading() ${snapshots.error}", name: '${runtimeType.toString()}:...');
          log("${snapshots.error}", name: '${runtimeType.toString()}:...');
          log("${snapshots.error}");
          return const Loading();
        }
      }
    );
  }
  // Auto Process Messages from Players active Queue.
  void autoProcess({required MessageTypeOption messageTypeOption}) async {
    int squareRequested = -1;
    // MessageTypeOption.acknowledgment
    log("Auto Processing ... type: $messageTypeOption (${messageType[messageTypeOption]})", name: '${runtimeType.toString()}:AutoProcess()');
    List<FirestoreDoc> fsDocs = await DatabaseService(FSDocType.messageowner, uid: activePlayer.uid ).fsDocList;
    List<MessageOwner> messageOwners = fsDocs.map((a) => a as MessageOwner).toList();
    for (MessageOwner mo in messageOwners ) {
      Player playerFrom = await DatabaseService(FSDocType.player, uid: activePlayer.uid).fsDoc(docId: mo.docId) as Player;
      log("Processing for Owner: ${mo.docId} Player: ${playerFrom.fName}", name: '${runtimeType.toString()}:AutoProcess()');

      List<FirestoreDoc> fsDocs = await DatabaseService(FSDocType.message, toUid: activePlayer.uid, fromUid: mo.uid ).fsDocList;
      List<Message> messages = fsDocs.map((a) => a as Message).toList();
      for (Message m in messages) {
        log("    Message: ${m.key} Type: ${m.messageType} : ${m.messageCode}", name: '${runtimeType.toString()}:AutoProcess()');

        if ( messageType[messageTypeOption] == m.messageType ) {
          log("    Message: ${m.key} Type: ${m.messageType} ***** Auto Processing", name: '${runtimeType.toString()}:AutoProcess()');
          log('Code: ${m.messageCode}:${messageDesc[m.messageCode]} From: ${playerFrom.fName} To: ${activePlayer.fName}',
              name: "${runtimeType.toString()}:AutoProcess()");
          // If this is a Request ... check if it is a Square Request.
          if ( messageTypeOption == MessageTypeOption.request ) {
            if ( 00040 == m.messageCode ) {
              log("Auto Process Request Square ... ", name: '${runtimeType.toString()}:AutoProcess()');
              ////
              Game? game = await DatabaseService(FSDocType.game, sidKey: Series.Key(m.data['sid']))
                  .fsDoc(docId: m.data['gid']) as Game;
              log('00040: Square value: ${game.squareValue}', name: '${runtimeType.toString()}:AutoProcess()');

              Grid? grid = await DatabaseService(FSDocType.grid, sidKey: Series.Key(m.data['sid']), gidKey: game.key)
                  .fsDoc(docId: m.data['gid']) as Grid;
              log("00040: grid player: ${grid.squarePlayer}, '${grid.squareInitials}' ", name: '${runtimeType.toString()}:AutoProcess()');

              Member? member = await DatabaseService(FSDocType.member, cidKey: Community.Key(m.data['cid']))
                  .fsDoc(docId: m.pidFrom) as Member;
              log('00040: Credits: ${member.credits}', name: '${runtimeType.toString()}:AutoProcess()');
              squareRequested = m.data['squareRequested'] ?? -1;
              if (member.credits >= game.squareValue) {
                if (grid.squarePlayer[squareRequested] == -1) {
                  log('Accepting Request and Replying ... ', name: '${runtimeType.toString()}:AutoProcess()');
                  member.credits -= game.squareValue;
                  grid.squarePlayer[squareRequested] = playerFrom.docId;
                  grid.squareInitials[squareRequested] = playerFrom.initials;
                  grid.squareCommunity[squareRequested] = m.data['cid'];
                  // Todo: Look at the need for awaits here
                  await DatabaseService(FSDocType.member, cidKey: Community.Key(m.data['cid'])).fsDocUpdate(member);
                  await DatabaseService(FSDocType.grid, sidKey: Series.Key(m.data['sid']), gidKey: game.key).fsDocUpdate(grid);
                  await DatabaseService(FSDocType.board, sidKey: Series.Key(m.data['sid']), gidKey: game.key)
                      .fsDocUpdateField(key: game.key, field: 'squaresPicked', ivalue: grid.getPickedSquares());
                  messageSend(10040, messageType[MessageTypeOption.acceptance]!,
                    playerFrom: activePlayer,
                    playerTo: playerFrom,
                    description: '${activePlayer.fName} ${activePlayer.lName} accepted your request for Square $squareRequested from Game <${game.name}>',
                    comment: "System generated square request accept",
                    data: m.data,
                  );
                } else {
                  continue;
                }
              } else {
                continue;
              }
              ////
            } else {
              continue; // Go to next message.
            }
          }
          messageArchive(message: m, playerFrom: playerFrom);
        }
      }
    }
  }
}