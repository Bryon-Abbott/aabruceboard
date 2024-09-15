import 'dart:developer';
import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_summary_tile.dart';
import 'package:bruceboard/services/databaseservice.dart';

part 'game_summary_ctlr.dart';

class GameSummaryPage extends StatefulWidget {
  const GameSummaryPage({super.key, required this.series, required this.game, required this.grid, required this.board});
  final Series series;
  final Game game;
  final Grid grid;
  final Board board;

  @override
  GameSummaryCtlr createState() => _GameSummaryPage();
}

class _GameSummaryPage extends GameSummaryCtlr {
  List<int> credits = List<int>.filled(5, 0);
  @override
  Widget build(BuildContext context) {
    List<int> playerNos = widget.grid.squarePlayer.toSet().toList();
    final Player communityPlayer = Provider.of<CommunityPlayerProvider>(context).communityPlayer;
    final Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    final bool isGameOwner = communityPlayer.docId == activePlayer.docId;

    var counts = widget.grid.squarePlayer.fold<Map<int, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });
    credits = getCredits();

    log("Player Summary $counts", name: "${runtimeType.toString()}:build()");
    return FutureBuilder<List<List<dynamic>>>(
    future: getWinners(board, communityPlayer),
    // initialData: List<List<dynamic>>.filled(2, [Player(data: {}), -1]),
    initialData: [
      [Player(data: {}), Player(data: {}), Player(data: {}), Player(data: {})], // Winner
      const [-1, -1, -1, -1],                                                   // Community
      const [-1, -1, -1, -1]                                                    // Square
    ],
    builder: (BuildContext context, AsyncSnapshot<List<List<dynamic>>> snapshot) {
      if (snapshot.hasData) {
        winnersPlayer = snapshot.data![0].cast<Player>(); // as List<Player>;
        winnersCommunity = snapshot.data![1].cast<int>(); // as List<int>;
        winnerSquare = snapshot.data![2].cast<int>(); // as List<int>;
      }
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Game: ${game.name} '),
            actions: [
              PopupMenuButton<int>(
                onSelected: (item) => onMenuSelected(context, item, board, series, activePlayer, communityPlayer),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 0,
                    enabled: isGameOwner && !board.creditsDistributed && board.scoresLocked,
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Distribute Credits"),
                      ]
                    )
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    enabled: isGameOwner && !board.scoresLocked,
                    child: const Row(
                      children: [
                        Icon(Icons.percent_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Update Splits"),
                      ]
                    )
                  ),
                ]
              )
            ],
          ),
          body: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                      List<Widget>.generate(1, (index) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Score:'),
                          ],
                        );
                      }) +
                      List.generate(4, (index) {
                        return Wrap(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SizedBox(
                                width: 21,
                                child: Text("Q${index + 1}"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                                ),
                                child: Text(board.colResults[index].toString(), textAlign: TextAlign.right),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, //.surfaceVariant,
                                ),
                                child: Text(board.rowResults[index].toString(), textAlign: TextAlign.right),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: SizedBox(
                                width: 32,
                                child: Text("Won"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                                ),
                                child: (!board.scoresLocked)
                                    ? const Text("Lock Digits")
                                    : (winnersPlayer[index].pid == -1)
                                        ? const Text("Enter Scores")
                                        : Text("${winnersPlayer[index].fName} ${winnersPlayer[index].lName}",
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                      ),
                                // child: Text(getWinners(board.rowResults[index], board.colResults[index], board)
                                //       .then((value) { return value; } )),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: SizedBox(
                                width: 33,
                                child: Text("Crds"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                                ),
                                // child: Text('Fix Me'),
                                child: Text(credits[index].toString(),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SizedBox(
                                height: 25,
                                width: 45,
                                child: ElevatedButton(
                                  onPressed: isGameOwner && !board.creditsDistributed
                                    ? () async {
                                        log("Getting Scores ... ", name: "${runtimeType.toString()}:buildScore");
                                        final List<String>? score = await openDialogScores(index, board);
                                        if (score == null || score.isEmpty) {
                                          return;
                                        } else {
                                          log("Loading Game Data ... GameNo: ${game.docId} ",
                                              name: "${runtimeType.toString()}:buildScore()");
                                          //gameData.loadData(game.gameNo!);
                                          if (score[0].isNotEmpty) {
                                            board.colResults[index] = int.parse(score[0]);
                                          }
                                          if (score[1].isNotEmpty) {
                                            board.rowResults[index] = int.parse(score[1]);
                                          }

                                          log("Saving Game Data ... GameNo: ${game.docId} ",
                                              name: "${runtimeType.toString()}:buildScore()");
                                          await DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
                                              .fsDocUpdate(board);
                                          setState(() {
                                            // reset state to reload players?
                                          });
                                        }
                                      }
                                    : null,
                                  child: const Text('Score'),
                                ),
                              ),
                            ),
                          ]
                        );
                      })+
                      List<Widget>.generate(1, (index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 231,
                              child: Text('Community:')
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: SizedBox(
                                width: 33,
                                child: Text("Crds"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                                ),
                                // Todo: Look at improving this.
                                child: Text(credits[4].toString(),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                            Text("="),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                padding: const EdgeInsets.all(1.0),
                                width: 35,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                                ),
                                // Todo: Look at improving this.
                                child: Text(credits[5].toString(),
                                    textAlign: TextAlign.right),
                              ),
                            ),
                          ],
                        );
                      })                        ,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(2.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Splits: "),
                    Row(
                      children:
                        [ const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text("Quarters"),
                          )
                        ] +
                        List.generate(4, (i) {
                          // return Text("$int");
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.outline),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                              ),
                              child: Text(board.percentSplits[i].toString(), textAlign: TextAlign.right),
                            ),
                          );
                        }) +
                        [ const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text("Community"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.outline),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
                              ),
                              child: Text(board.percentSplits[4].toString(), textAlign: TextAlign.right),
                            ),
                          )
                        ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ListView.builder(
                    itemCount: playerNos.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Squares Selected"),
                          GameSummaryTile(playerNo: playerNos[index], count: counts[playerNos[index]] ?? -1),
                        ]);
                      } else {
                        return GameSummaryTile(playerNo: playerNos[index], count: counts[playerNos[index]] ?? -1);
                      }
                    },
                  ),
                ),
              ),
              (kIsWeb) ? const SizedBox() : const AaBannerAd(),
            ],
          ),
        ),
      );
    });
  }


}
