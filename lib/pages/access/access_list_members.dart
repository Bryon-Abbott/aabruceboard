import 'dart:developer';
import 'package:bruceboard/pages/access/access_tile_member.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
// Todo: Implement delete

class AccessListMembers extends StatefulWidget {
  final Series series;
  const AccessListMembers( {super.key, required this.series} );

  @override
  State<AccessListMembers> createState() => _AccessListState();
}

class _AccessListState extends State<AccessListMembers> {
  late BruceUser bruceUser;
  late Series series;

  @override
  void initState() {
    super.initState();
    series = widget.series;
  }

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);
    Player? player;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.access, sidKey: series.key).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Access> accessList = snapshots.data!.map((s) => s as Access).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Select Member - Series: ${series.name}'),
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
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: accessList.length,
              itemBuilder: (context, index) {
                return AccessTileMembers(access: accessList[index]);
              },
            ),
          );
        } else {
          log("membership_list: Snapshot Error ${snapshots.error}");
          return const Loading();
        }
      }
    );
  }
}