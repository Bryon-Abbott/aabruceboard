import 'dart:developer';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/pages/series/series_tile.dart';

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

    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.series).fsDocListStream, // as Stream<List<Series>>,
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            List<Series> series = snapshots.data!.map((s) => s as Series).toList();
            return Scaffold(
              appBar: AppBar(
                title: Text('Manage Groups'),
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
                  //     log('Group Report-Detail: ',
                  //         name: "${runtimeType.toString()}:build()" );
                  //   },
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.view_compact_alt_outlined),
                  //   onPressed: () {
                  //     log('Group Report-Summary: ',
                  //         name: "${runtimeType.toString()}:build()" );
                  //   },
                  // ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () async {
                      dynamic changes = await Navigator.pushNamed(context, '/series-maintain');
                      if (changes != null) {
                        log('Games $changes Changes Type : ${changes.runtimeType}', name: '${runtimeType.toString()}:build()');
                      } else {
                        log('**null** Changes Type : ${changes.runtimeType}', name: '${runtimeType.toString()}:build()');
                      }
                    },
                  )
                ]
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        return SeriesTile(series: series[index]);
                      },
                    ),
                  ),
                  const AdContainer(),
//                  (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                ],
              ),
            );
          } else {
            log("Snapshot Error ${snapshots.error} ... loading", name: '${runtimeType.toString()}:build()');
            return const Loading();
          }
        }
      ),
    );
  }
}