import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayer.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_access_list.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class SeriesAccessTile extends StatelessWidget {
  final Access access;
  const SeriesAccessTile({super.key, required this.access});

  @override
  // Todo: Change to Future builder to set Series
  Widget build(BuildContext context) {
    Series? series;
    CommunityPlayer communityPlayerProvider = Provider.of<CommunityPlayer>(context);
    Player communityPlayer= communityPlayerProvider.communityPlayer;

    // Get Player
    return FutureBuilder<FirestoreDoc?>(
      future: DatabaseService(FSDocType.series, uid: communityPlayer.uid)
              .fsDoc(docId: access.sid),
      builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
        if (snapshot.hasData) {
          series = snapshot.data as Series;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Card(
              margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: ListTile(
                onTap: () {
                  log("Series Tapped ... ${series?.name ?? '...'} ", name: '${runtimeType.toString()}:...');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GameAccessList(
                        series: series!
                      )
                    ),
                  );
                },
                leading: const Icon(Icons.list_alt_outlined),
                title: Text('Name: ${series?.name ?? '...'}'),
                subtitle: Text(
                    'Series: ${Player.Key(access.pid)}:${Community.Key(access.cid)}:${Series.Key(access.sid)} (${series?.noGames ?? '..'}) *'),
                trailing: IconButton(
                  onPressed: () {
                    //   Navigator.of(context).push(
                    //       MaterialPageRoute(builder: (context) => SeriesMaintain(series: series)));
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
          );
        } else {
          log('series_access_tile: AccessPlayer Snapshot has no data ... ', name: '${runtimeType.toString()}:...');
          return const Loading();
        }
      }
    );
  }
}
