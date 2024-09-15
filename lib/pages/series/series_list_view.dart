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
    return StreamBuilder<FirestoreDoc>(
      stream: DatabaseService(FSDocType.series, uid: widget.communityOwner.uid)
          .fsDocStream(docId: widget.access.sid),
      builder: (context, snapshotSeries) {
        if (snapshotSeries.hasData) {
          Series series = snapshotSeries.data as Series;
          log("Series-Series (${widget.access.key}) Status: ${series.status}...", name: '${runtimeType.toString()}:build():Series-ListView.builder');
          if (series.status == StatusValues.active.index) {
            return SeriesTileView(
                membership: widget.membership,
                seriesOwner: widget.communityOwner,
                series: series
            );
          } else {
            return const SizedBox();
          }
        } else {
          log("Series-Series Snapshot Error ${snapshotSeries.error} ... loading", name: '${runtimeType.toString()}:build()');
          return const Loading();
        }
      }
    );
  }
}