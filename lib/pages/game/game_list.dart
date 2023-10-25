import 'dart:developer';

import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/pages/game/game_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';

class GameList extends StatefulWidget {
  final Series series;

  const GameList({super.key, required this.series});

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  @override
  Widget build(BuildContext context) {

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<Game>>(
      stream: DatabaseService(pid: bruceUser.uid, sid: widget.series.sid).gameList,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Game> game = snapshots.data!;
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: const Text('Manage Game'),
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
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GameMaintain(series: widget.series)));
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: game.length,
              itemBuilder: (context, index) {
                return GameTile(series: widget.series, game: game[index]);
              },
            ),
          );
        } else {
          return Loading();
        }
      }
    );
    }
  }