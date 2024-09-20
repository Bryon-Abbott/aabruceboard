import 'dart:developer';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/pages/message/message_tile_processed.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class MessageListProcessed extends StatefulWidget {
  const MessageListProcessed({super.key, required this.activePlayer});
  final Player activePlayer;

  @override
  State<MessageListProcessed> createState() => _MessageListProcessedState();
}

class _MessageListProcessedState extends State<MessageListProcessed> {

  late Player activePlayer;
  Player? filterPlayer;
  // late Message message;

  @override
  void initState() {
    super.initState();
    activePlayer = widget.activePlayer;
  }

  @override
  Widget build(BuildContext context) {

//    activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.message, )
          .fsDocGroupListStream(group: "Processed", pidTo: activePlayer.pid, pidFrom: filterPlayer?.pid ?? 0),   // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Message> message = snapshots.data!.map((a) => a as Message).toList();
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                  title: Text('Show Processed Message - Count: ${message.length}'),
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
                        dynamic playerSelected = await Navigator.pushNamed(
                            context, '/player-select');
                        if (playerSelected != null) {
                          setState((){
                            filterPlayer = playerSelected as Player;
                          });
                          log('Filter Player Selected ${filterPlayer!.fName}');
                        } else {
                          log("No filter player selected");
                        }
                      },
                      tooltip: "Filter player",
                      icon: const Icon(Icons.filter_alt_outlined),
                    )
                  ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: message.length,
                      itemBuilder: (context, index) {
                        return MessageTileProcessed(message: message[index]);
                      },
                    ),
                  ),
                  const AdContainer(),
//                  (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                ],
              ),
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
}