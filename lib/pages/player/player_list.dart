import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/player/player_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({super.key});

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.series, uid: bruceUser.uid).fsDocList, // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Player> player = snapshots.data!.map((s) => s as Player).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Player - Count: ${player.length}'),
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
                      dynamic changes = await Navigator.pushNamed(
                          context, '/player-maintain');
                      if (changes != null) {
                        log('player_list: Games $changes Changes Type : ${changes.runtimeType}');
                      } else {
                        log('player_list: **null** Changes Type : ${changes.runtimeType}');
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: player.length,
              itemBuilder: (context, index) {
                return PlayerTile(player: player[index]);
              },
            ),
          );
        } else {
          log("player_list: Snapshot Error ${snapshots.error}");
          return const Loading();
        }
      }
    );
    }
  }