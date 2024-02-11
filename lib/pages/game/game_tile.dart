import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/pages/game/game_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameTile extends StatelessWidget {
  final Series series;
  final Game game;
  final Function callback;


  const GameTile({super.key,  required this.callback, required this.series, required this.game });

  @override
  Widget build(BuildContext context) {

    Player activePlayer =  Provider.of<ActivePlayerProvider>(context).activePlayer;

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
          subtitle: Text(' SID: ${series.key} GID: ${game.key}'),
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
  }
}