import 'dart:developer';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/pages/access/access_tile_series.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

//

class AccessListSeries extends StatefulWidget {
  final Membership membership;
  const AccessListSeries({super.key, required this.membership});

  @override
  State<AccessListSeries> createState() => _AccessListSeriesState();
}

class _AccessListSeriesState extends State<AccessListSeries> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);

    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
          stream: DatabaseService(FSDocType.access)
            .fsDocGroupListStream(
              "Access",
              queryFields: {'pid': widget.membership.cpid, 'cid': widget.membership.cid},
              // ToDo: Look to implement and in(1, 2) or 1 or 2 to include group status in query.
              //  whereInFields: {'status': [1,2]}
              // orderFields: {'gameDate': false},
            ),
        // stream: DatabaseService(FSDocType.access)
        //     .fsDocGroupListStream(group: "Access", pid: widget.membership.cpid, cid: widget.membership.cid),   // as Stream<List<Series>>,
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            List<Access> access = snapshots.data!.map((a) => a as Access).toList();
            return Scaffold(
              appBar: AppBar(
        //            backgroundColor: Colors.blue[900],
                  title: Text('Show Board Groups'),
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    // if user presses back, cancels changes to list (order/deletes)
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: const [
                    IconButton(
                      onPressed: null,
                      // onPressed: () {
                      //   log("+ Button pressed", name: '${runtimeType.toString()}:build()');
                      // },
                      icon: Icon(Icons.add_circle_outline),
                    )
                  ]),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: access.length,
                      itemBuilder: (context, index) {
                        return AccessTileSeries(access: access[index]);
                      },
                    ),
                  ),
                  const AdContainer(),
//                  (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                ],
              ),
            );
          } else {
            log("build: Snapshot is ${snapshots.error}", name: '${runtimeType.toString()}:...');
            return const Loading();
          }
        }
      ),
    );
    }
  }