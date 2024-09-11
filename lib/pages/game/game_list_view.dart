import 'dart:math';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_list.dart';
import 'package:bruceboard/pages/game/game_tile_view.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameListView extends StatefulWidget {
  final Player seriesOwner;
  final Series series;

  const GameListView({super.key,
    required this.seriesOwner,
    required this.series,
  });

  @override
  State<GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends State<GameListView> {
  @override
  Widget build(BuildContext context) {
    Board board;
    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.game, uid: widget.seriesOwner.uid, sidKey: widget.series.key ).fsDocQueryListStream(
        queryValues: { 'status': 1 }
      ),
      builder: (context, snapshotsGame) {
        if (snapshotsGame.hasData) {
          List<Game> games = snapshotsGame.data!.map((g) => g as Game).toList();
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.green[800]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Group: ${widget.series.type}:${widget.series.name}"),
                        // Text("(${widget.series.key})"),
                        Spacer(),
                        Text("(Active Games: ${games.length})  "),
                        // ToDo: Make this a Double Chevron Button
                        IconButton(
                          icon: const Icon(Icons.double_arrow_outlined),
                          tooltip: 'Go to Group',
                          onPressed: () {
                            Provider.of<CommunityPlayerProvider>(context, listen: false).communityPlayer = widget.seriesOwner;
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => GameList(series: widget.series)));
                          },
                        ),
                        //Text("Active Games: ${games.length}"),
                      ],
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: min(games.length, 2),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return FutureBuilder<FirestoreDoc?>(
                          future: DatabaseService(FSDocType.board,
                              uid: widget.seriesOwner.uid,
                              sidKey: widget.series.key,
                              gidKey: games[index].key)
                            .fsDoc(docId: games[index].docId),
                          builder: (context, snapshotBoard) {
                            if (snapshotBoard.hasData) {
                              board = snapshotBoard.data as Board;
                              return GameTileView(
                                gamesCount: games.length,
                                game: games[index],
                                gameOwner: widget.seriesOwner,
                                board: board
                              );
                            } else {
                              return const Loading();
                            }
                          }
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Loading();
        }
      }
    );
  }
}
