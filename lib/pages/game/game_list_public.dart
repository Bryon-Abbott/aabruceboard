import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/game/game_tile_public.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class GameListPublic extends StatefulWidget {
  const GameListPublic({super.key});

  @override
  State<GameListPublic> createState() => _GameListPublicState();
}

class _GameListPublicState extends State<GameListPublic> {
  @override
  Widget build(BuildContext context) {
    // Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.game).fsDocGroupListStream2(
        "Game",
        queryFields: {'permission': 1, 'status': 1},
        orderFields: {'gameDate': false},
      ),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          List<Game> game = snapshot.data!.map((g) => g as Game).toList();
          return ListView.builder(
            itemCount: game.length,
            itemBuilder: (context, index) {
              return FutureBuilder<FirestoreDoc?>(
                future: DatabaseService(FSDocType.player).fsDoc(docId: game[index].pid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Player gameOwner = snapshot.data as Player;
                    return GameTilePublic(game: game[index], gameOwner: gameOwner);
                  } else {
                    return const Loading();
                  }
                }
              );
            }
          );
        } else {
          return const Loading();
        }
      }
    );
  }
}
