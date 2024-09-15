import 'dart:developer';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GameTilePublic extends StatelessWidget {
  final Game game;
  final Player gameOwner;

  const GameTilePublic({super.key, required this.game, required this.gameOwner });

  @override
  Widget build(BuildContext context) {
    //StatusValues status = StatusValues.values[game.status];
    //Player activePlayer =  Provider.of<ActivePlayerProvider>(context).activePlayer;
    String iconSvg = getHarveyBallSvg(0);
    Board? board;
    Series? series;
    return StreamBuilder<FirestoreDoc>(
      stream: DatabaseService(FSDocType.board, uid: gameOwner.uid, gidKey: Game.Key(game.docId), sidKey: Series.Key(game.sid))
          .fsDocStream(key: Board.Key(game.docId)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          board = snapshot.data as Board;
          iconSvg = getHarveyBallSvg(board!.squaresPicked);
        }
        return FutureBuilder<FirestoreDoc?>(
          future: DatabaseService(FSDocType.series, uid: gameOwner.uid, sidKey: Series.Key(game.sid))
              .fsDoc(key: Series.Key(game.sid)),
          builder: (context, snapshotSeries) {
            if (snapshotSeries.hasData) {
              series = snapshotSeries.data as Series;
            }
            return Card(
              margin: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
              child: ListTile(
                onTap: () async {
                  log("Game Tapped ... ${game.name} ", name: '${runtimeType.toString()}:build()');
                  Access? access = await hasAccess(spid: game.pid, sid: game.sid);
                  if (access == null) {
                    log("No Access Found ... Request Access   ", name: '${runtimeType.toString()}:build()');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Request Access from ${gameOwner.fName} ${gameOwner.lName} through the 'Membership' icon"))
                      );
                    }
                  } else {
                    log("Access Found ... Go to Communities ${Access.KEY(access.pid, access.cid)} ", name: '${runtimeType.toString()}:build()');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Access game through 'My Community' tab or 'Memberships' icon"))
                      );
                    }
                  }
                  // await Navigator.of(context).push(
                  //   MaterialPageRoute(builder: (context) => GameBoard(series: series, game: game)),
                  // );
                },
                //            leading: const Icon(Icons.sports_football_outlined),
                leading: SvgPicture.asset(iconSvg,
                  width: 36, height: 36,
                  //   colorFilter: ,
                ),
                title: Text('Game: ${game.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group: ${series?.type ?? "..."}-${series?.name ?? "..."} (${gameOwner.fName} ${gameOwner.lName})'),
                    Text('Date: ${game.gameDate}')
                  ],
                ),
                // subtitle: Row(
                //   children: [
                //     Text('${series?.key ?? -1}:${game.key}'),
                //     const Spacer(),
                //     Text(status.name),
                //   ],
                // ),
                // trailing: IconButton(
                //   onPressed: (series != null && game.pid == activePlayer.pid)
                //       ? () async {
                //     await Navigator.of(context).push(
                //         MaterialPageRoute(builder: (context) => GameMaintain(series: series!, game: game)));
                //   }
                //       : null,
                //   icon: const Icon(Icons.edit),
                // ),
              ),
            );
          }
        );
      }
    );
  }

  Future<Access?> hasAccess({required int spid, required int sid}) async {
    Access? access;

    // Get Players Memberships
    List<FirestoreDoc> fsDocs = await DatabaseService(FSDocType.membership).fsDocList;
    List<Membership> memberships = fsDocs.map((m) => m as Membership).toList();

    // Get Series Accesses
    List<FirestoreDoc> fsDocs2 = await DatabaseService(FSDocType.access).fsDocGroupList(
      "Access", queryFields: {'pid': spid, 'sid': sid});
    List<Access> accesses = fsDocs2.map((a) => a as Access).toList();

    // Compare Membership and Accesses to see if there is a match
    for ( Membership m in memberships ) {
      log("Looking for Access for Membership ${m.key}   ", name: '${runtimeType.toString()}:build()');
      // Get All Community Accesses for given series
      for ( Access a in accesses ) {
        if ((a.cid == m.cid) && (a.pid == m.cpid)) {
          access = a;
          break;
        }
      }
      // If an Access found break out and return access.
      if ( access != null ) break;
    }
    return Future.value(access);
  }
}