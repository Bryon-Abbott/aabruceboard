import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/pages/game/game_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/menus/popupmenubutton_status.dart';

class GameTile extends StatelessWidget {
  final Series series;
  final Game game;
  final Function callback;


  const GameTile({super.key,  required this.callback, required this.series, required this.game });

  @override
  Widget build(BuildContext context) {
    StatusValues status = StatusValues.values[game.status];
    Player activePlayer =  Provider.of<ActivePlayerProvider>(context).activePlayer;
    // Exclude games for non-owners where game status is Prepare or Archived.
    if ((activePlayer.pid == game.pid) || (game.status == 1) || (game.status == 2) ){
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Card(
          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            onTap: () async {
              log("Game Tapped ... ${game.name} ", name: '${runtimeType.toString()}:build()');
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GameBoard(series: series, game: game)),
              );
            },
            leading: const Icon(Icons.sports_football_outlined),
            title: Text('Game: ${game.name}'),
            subtitle: Row(
              children: [
                Text('${series.key}:${game.key}'),
                const Spacer(),
                Text(status.name),
              ],
            ),
            trailing: IconButton(
              onPressed: (game.pid == activePlayer.pid)
                  ? () async {
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GameMaintain(series: series, game: game)));
                callback();
              }
                  : null,
              icon: const Icon(Icons.edit),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }

  }
}