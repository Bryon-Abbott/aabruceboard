import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/pages/message/message_tile_incoming.dart';
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
  late Message message;

  @override
  Widget build(BuildContext context) {

    activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.message, )
          .fsDocGroupListStream(group: "Incoming", pidTo: activePlayer.pid),   // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Message> message = snapshots.data!.map((a) => a as Message).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
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
          print("${snapshots.error}");
          return const Loading();
        }
      }
    );
    }
  }