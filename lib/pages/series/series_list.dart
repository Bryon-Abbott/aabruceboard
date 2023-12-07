import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/series/series_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class SeriesList extends StatefulWidget {
  const SeriesList({super.key});

  @override
  State<SeriesList> createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
      // stream: DatabaseService(FSDocType.series, uid: bruceUser.uid).fsDocList.cast<List<Series>>(), // as Stream<List<Series>>,
      stream: DatabaseService(FSDocType.series).fsDocList, // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Series> series = snapshots.data!.map((s) => s as Series).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Series - Count: ${series.length}'),
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
                      dynamic changes = await Navigator.pushNamed(context, '/series-maintain');
                      if (changes != null) {
                        log('series_list: Games $changes Changes Type : ${changes.runtimeType}');
                      } else {
                        log('series_list: **null** Changes Type : ${changes.runtimeType}');
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, index) {
                return SeriesTile(series: series[index]);
              },
            ),
          );
        } else {
          log("series_list: Snapshot Error ${snapshots.error}");
          return const Loading();
        }
      }
    );
    }
  }