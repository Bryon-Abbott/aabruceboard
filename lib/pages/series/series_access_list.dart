import 'dart:developer';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/series/series_access_tile.dart';
import 'package:bruceboard/pages/series/series_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class SeriesAccessList extends StatefulWidget {
  final Membership membership;
  SeriesAccessList({super.key, required this.membership});

  @override
  State<SeriesAccessList> createState() => _SeriesAccessListState();
}

class _SeriesAccessListState extends State<SeriesAccessList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.access)
          .fsDocGroupListStream(pid: widget.membership.cpid, cid: widget.membership.cid),   // as Stream<List<Series>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Access> access = snapshots.data!.map((a) => a as Access).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Show Series Access - Count: ${access.length}'),
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
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: access.length,
              itemBuilder: (context, index) {
                return SeriesAccessTile(access: access[index]);
              },
            ),
          );
        } else {
          log("build: Snapshot is ${snapshots.error}", name: '${runtimeType.toString()}:...');
          return const Loading();
        }
      }
    );
    }
  }