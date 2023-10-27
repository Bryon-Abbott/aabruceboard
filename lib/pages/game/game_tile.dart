import 'dart:developer';

import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/pages/game/game_board.dart';
import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final Series series;
  final Game game;
  final Function callback;

  GameTile({ required this.callback, required this.series, required this.game });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () async {
            log("Game Tapped ... ${game.name} ");
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => GameBoard(game: game)),
            );
          },
          leading: Icon(Icons.sports_football_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Game: ${game.name}'),
          subtitle: Text(' SID: ${game.sid} GID: ${game.gid}'),
          trailing: IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GameMaintain(series: series, game: game)));
              callback();
            },
            icon: Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}