import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
// import 'package:bruceboard/models/member.dart';
// import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';
// import 'package:bruceboard/pages/member/member_maintain.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class GameSummaryTile extends StatelessWidget {
  final int playerNo;
  final int count;

  const GameSummaryTile({super.key, required this.playerNo, required this.count });

  @override
  Widget build(BuildContext context) {
    if (playerNo == -1) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Card(
          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            onTap: ()  {
              log("Player Tapped ... Free : Square ");
            },
            leading: const Icon(Icons.person_outline),
            title: Text('Free Squares: $count'),
            //subtitle: Text('Game ... '),
          ),
        ),
      );
    } else {
      return StreamBuilder<FirestoreDoc>(
        stream: DatabaseService(FSDocType.player).fsDocStream(docId: playerNo),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Player player = snapshot.data as Player;
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                child: ListTile(
                  onTap: ()  {
                    log("Player Tapped ... ${player.fName} : ${player.lName} ");
                  },
                  leading: const Icon(Icons.person_outline),
                  title: Text('${player.fName} ${player.lName}: $count',
                      style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  //subtitle: Text('Game ... '),
                ),
              ),
            );
          } else {
            log("member_tile: Snapshot Error ${snapshot.error}");
            return const Loading();
          }
        });
    }
  }
}