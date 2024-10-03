import 'dart:developer';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bruceboard/menus/popupmenubutton_status.dart';

class GameTileView extends StatelessWidget {
  final int gamesCount;
  final Game game;
  final Player gameOwner;
  final Board board;

  const GameTileView({super.key,
    required this.gamesCount,
    required this.game,
    required this.gameOwner,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    StatusValues status = StatusValues.values[game.status];
    String iconSvg = getHarveyBallSvg(board.squaresPicked);
    return Card(
      margin: const EdgeInsets.fromLTRB(2.0, 2.0, 30.0, 2.0),
      child: ListTile(
        onTap: () async {
          log("Pool Tapped ... ${game.name} ", name: '${runtimeType.toString()}:build()');
          // await Navigator.of(context).push(
          //   MaterialPageRoute(builder: (context) => GameBoard(series: series, game: game)),
          // );
        },
        //            leading: const Icon(Icons.sports_football_outlined),
        leading: SvgPicture.asset(iconSvg,
          width: 36, height: 36,
          //   colorFilter: ,
        ),
        title: Text('Pool: ${game.name}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${game.gameDate} Status: ${status.name}'),
          ],
        ),
      ),
    );
  }
}