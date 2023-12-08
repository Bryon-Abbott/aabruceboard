import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/pages/community/community_tile.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class CommunityList extends StatefulWidget {
  const CommunityList({super.key});

  @override
  State<CommunityList> createState() => _CommunityListState();
}

class _CommunityListState extends State<CommunityList> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.community).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Community> community = snapshots.data!.map((s) => s as Community).toList();
          return Scaffold(
            appBar: AppBar(
                title: Text('Manage Community - Count: ${community.length}'),
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
                      dynamic changes = await Navigator.pushNamed(
                          context, '/community-maintain');
                      if (changes != null) {
                        log('community_list: Members $changes Changes Type : ${changes.runtimeType}');
                      } else {
                        log('community_list: **null** Changes Type : ${changes.runtimeType}');
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: community.length,
              itemBuilder: (context, index) {
                return CommunityTile(community: community[index]);
              },
            ),
          );
        } else {
          log("community_list: Snapshot Error ${snapshots.error}");
          return const Loading();
        }
      }
    );
    }
  }