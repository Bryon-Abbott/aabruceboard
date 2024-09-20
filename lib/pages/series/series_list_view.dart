import 'dart:developer';
import 'package:bruceboard/menus/popupmenubutton_status.dart';
import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/pages/series/series_tile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class SeriesListView extends StatefulWidget {
  final Player communityOwner;
  final Community community;
  final Membership membership;
  final Access access;

  const SeriesListView({super.key,
    required this.communityOwner,
    required this.community,
    required this.membership,
    required this.access,
  });

  @override
  State<SeriesListView> createState() => _SeriesListViewState();
}

// class Community {
// }

class _SeriesListViewState extends State<SeriesListView> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

  bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
        // stream: DatabaseService(FSDocType.game, uid: widget.seriesOwner.uid, sidKey: widget.series.key )
        //   .fsDocQueryListStream(
        //     queryValues: { 'status': 1 }
        //   ),
        // stream: DatabaseService(FSDocType.series, uid: widget.communityOwner.uid)
        //     .fsDocStream(docId: widget.access.sid),
      stream: DatabaseService(FSDocType.series, uid: widget.communityOwner.uid)
        .fsDocQueryListStream(
          queryValues: {
            'docId': widget.access.sid,
            'status': StatusValues.active.index }
        ),
      builder: (context, snapshotsSeries) {
        if (snapshotsSeries.hasData) {
          List<Series> series = snapshotsSeries.data!.map((s) => s as Series).toList();
//          Series series = snapshotSeries.data as Series;
          log("Series-Series (${widget.access.key}) Series Count: ${series.length}...",
              name: '${runtimeType.toString()}:build():Series-ListView.builder');
          if (series.length > 0) {
            return SeriesTileView(
                membership: widget.membership,
                seriesOwner: widget.communityOwner,
                series: series[0]
            );
          } else {
            // return Text("Series ... loading() ${widget.access.sid} ");
            return const SizedBox();
          }
        } else {
          // If series is not active (ie No Series Returned) ... return nothing.
          log("Series-Series Snapshot Error ${snapshotsSeries.error} ... loading",
              name: '${runtimeType.toString()}:build()');
          return const SizedBox();
          //return Text("Series ... loading() ${widget.access.sid} ");
          // return const Loading();
        }
      }
    );
  }
}