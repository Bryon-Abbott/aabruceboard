import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/game/game_summary_tile.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

part 'game_summary_ctlr.dart';

class GameSummaryPage extends StatefulWidget {
  GameSummaryPage({super.key, required this.game, required this.grid});
  Game game;
  Grid grid;

  @override
  // createState() => _GameSummaryPage();
  GameSummaryCtlr createState() => _GameSummaryPage();
  // State<GameSummaryPage> createState() => _GameSummaryPageState();
}

class _GameSummaryPage extends GameSummaryCtlr {
  @override
  Widget build(BuildContext context) {
    List<int> playerNos = widget.grid.squarePlayer.toSet().toList();
    List<Player> playerName = [];

    var counts = widget.grid.squarePlayer.fold<Map<int, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });
    log("Player Summary $counts", name: "${runtimeType.toString()}:build()");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Game: ${game.name} '),
        ),
        body: ListView.builder(
          itemCount: playerNos.length,
          itemBuilder: (context, index) {
            return GameSummaryTile(playerNo: playerNos[index], count: counts[playerNos[index]] ?? -1);
          },
        ),
      ),
    );
  }
}