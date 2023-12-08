import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/pages/message/message_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class MessageOwnerList extends StatefulWidget {
  const MessageOwnerList({super.key});

  @override
  State<MessageOwnerList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageOwnerList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);

    return
      SingleChildScrollView(
        child: SizedBox(
          height: 800,
          child: StreamBuilder<List<FirestoreDoc>>(
          stream: DatabaseService(FSDocType.messageowner, toUid: bruceUser.uid).fsDocListStream, // as Stream<List<Message>>,
          builder: (context, snapshots) {
            if(snapshots.hasData) {
              List<MessageOwner> messageOwner = snapshots.data!.map((s) => s as MessageOwner).toList();
              return Scaffold(
                appBar: AppBar(
                    title: Text('Manage Message - Count: ${messageOwner.length}'),
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
                        onPressed: () async {
                          dynamic changes = await Navigator.pushNamed(context, '/message-maintain');
                          if (changes != null) {
                            log('message_list: Games $changes Changes Type : ${changes.runtimeType}');
                          } else {
                            log('message_list: **null** Changes Type : ${changes.runtimeType}');
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      )
                    ]),
                body: ListView.builder(
                  itemCount: messageOwner.length,
                  itemBuilder: (context, index) {
                    return MessageList(messageOwner: messageOwner[index]);
                  },
                ),
              );
            } else {
              log("message_list: Snapshot Error ${snapshots.error}");
              return const Loading();
            }
          }
              ),
        ),
      );
    }
  }