import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_tile.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class GameList extends StatefulWidget {
  final Series series;

  const GameList({super.key, required this.series});

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  late Series series;

  @override
  void initState() {
    series = widget.series;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    void callback() {
      setState(() { });
    }

    CommunityPlayerProvider communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context) ;
    Player communityPlayer = communityPlayerProvider.communityPlayer;
    Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    log('Game Owner: ${communityPlayer.docId}:${communityPlayer.fName}', name: "${runtimeType.toString()}:build()" );

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.game, uid: communityPlayer.uid, sidKey: series.key).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Game> game = snapshots.data!.map((g) => g as Game).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('List Games - Count: ${series.noGames}/${game.length}'),
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
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: (activePlayer.pid != communityPlayer.pid) ? null : () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GameMaintain(series: series)));
                      setState(() {}); // Set state to refresh series changes.
                    },
                  )
                ]),
            body: ListView.builder(
              itemCount: game.length,
              itemBuilder: (context, index) {
                return GameTile(callback: callback, series: series, game: game[index]);
              },
            ),
          );
        } else {
          return const Loading();
        }
      }
    );
    }
  }