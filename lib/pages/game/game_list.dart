import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_tile.dart';
import 'package:bruceboard/pages/game/game_maintain.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class GameList extends StatefulWidget {
  final Series series;

  const GameList({super.key, required this.series});

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  late Series series;

  @override
  void initState() {
    series = widget.series;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    void callback() {
      setState(() { });
    }

    CommunityPlayerProvider communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context) ;
    Player communityPlayer = communityPlayerProvider.communityPlayer;
    Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    log('Board Owner: ${communityPlayer.docId}:${communityPlayer.fName}', name: "${runtimeType.toString()}:build()" );

    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.game, uid: communityPlayer.uid, sidKey: series.key).fsDocListStream,
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            List<Game> game = snapshots.data!.map((g) => g as Game).toList();
            return Scaffold(
              appBar: AppBar(
                  title: Text('Manage Boards: ${series.type}-${series.name}'),
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
                    // IconButton(
                    //   icon: const Icon(Icons.view_headline_outlined),
                    //   onPressed: () {
                    //     // Navigator.of(context).push(
                    //     //     MaterialPageRoute(builder: (context) => AuditReport(series: series)));
                    //     log('Game Report-Detail: ${communityPlayer.docId}:${communityPlayer.fName}',
                    //         name: "${runtimeType.toString()}:build()" );
                    //   },
                    // ),
                    // IconButton(
                    //   icon: const Icon(Icons.view_compact_alt_outlined),
                    //   onPressed: () {
                    //     log('Game Report-Summary: ${communityPlayer.docId}:${communityPlayer.fName}',
                    //         name: "${runtimeType.toString()}:build()" );
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: (activePlayer.pid != communityPlayer.pid) ? null : () async {
                        await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => GameMaintain(series: series)));
                        setState(() {}); // Set state to refresh series changes.
                      },
                    )
                  ]),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: game.length,
                      itemBuilder: (context, index) {
                        return GameTile(callback: callback, series: series, game: game[index]);
                      },
                    ),
                  ),
//                  const SizedBox(height: 8.0),
                  const AdContainer(),
//                  (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                ],
              ),
            );
          } else {
            return const Loading();
          }
        }
      ),
    );
    }
  }