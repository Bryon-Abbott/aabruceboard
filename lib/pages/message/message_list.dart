import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/pages/message/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key, required this.messageOwner});
  final MessageOwner messageOwner;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    final bruceUser = Provider.of<BruceUser>(context, listen: false);
    log('message_list: Getting Player U:${widget.messageOwner.uid}');
    // Player player = DatabaseService(FSDocType.player).fsDoc(key: widget.messageOwner.uid) as Player;

    return StreamBuilder<FirestoreDoc>(
      stream: DatabaseService(FSDocType.player).fsDocStream(key: widget.messageOwner.uid),
      builder: (context, snapshots) {
        if (snapshots.hasData) {
          Player player = snapshots.data as Player;
          log('message_list: Got Player fName:${player.fName}');
          return StreamBuilder<List<FirestoreDoc>>(
              stream: DatabaseService(FSDocType.message, toUid: bruceUser.uid,
                  fromUid: widget.messageOwner.uid).fsDocList,
              // as Stream<List<Message>>,
              builder: (context, snapshots) {
                if (snapshots.hasData) {
                  List<Message> message = snapshots.data!.map((s) => s as Message).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Message Owner: ${widget.messageOwner.docId} Player: ${player.fName} ${player.lName}"),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: message.length,
                          itemBuilder: (context, index) {
                            return MessageTile(message: message[index]);
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  log("message_list: Snapshot Error ${snapshots.error}");
                  return const Loading();
                }
              }
          );
        } else {
          log("message_list: Snapshot Error ${snapshots.error}");
          return const Loading();
        }
      }
    );
  }
}