import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_access_tile.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/pages/game/game_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class GameAccessList extends StatefulWidget {
  final Series series;
  final Player seriesPlayer;

  const GameAccessList( {super.key, required this.series, required this.seriesPlayer} );

  @override
  _GameAccessListState createState() => _GameAccessListState();
}

class _GameAccessListState extends State<GameAccessList> {
  late Series series;
  late Player seriesPlayer;

  @override
  void initState() {
    series = widget.series;
    seriesPlayer = widget.seriesPlayer;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    void callback() {
      setState(() { });
    }

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.game, uid: seriesPlayer.uid, sidKey: series.key).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Game> game = snapshots.data!.map((g) => g as Game).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Show Games Access - Count: ${series.noGames}/${game.length}'),
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
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GameMaintain(series: series)));
                      setState(() {}); // Set state to refresh series changes.
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: game.length,
              itemBuilder: (context, index) {
                return GameAccessTile(callback: callback, series: series, game: game[index]);
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