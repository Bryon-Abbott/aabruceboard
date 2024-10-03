import 'dart:developer';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/pages/access/access_tile_view.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class AccessListView extends StatefulWidget {
  final Player communityOwner;
  final Community community;
  final Membership membership;

  const AccessListView( {super.key,
    required this.communityOwner,
    required this.community,
    required this.membership,
  });

  @override
  State<AccessListView> createState() => _AccessListViewState();
}

class _AccessListViewState extends State<AccessListView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FirestoreDoc>>(
//    stream: DatabaseService(FSDocType.access, sidKey: series.key).fsDocListStream,
      stream: DatabaseService(FSDocType.access).fsDocGroupListStream("Access",
        queryFields: {'pid': widget.community.pid, 'cid': widget.community.docId,},
      ),
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Access> accessList = snapshots.data!.map((s) => s as Access).toList();
          return ListView.builder(
            itemCount: accessList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return AccessTileView(
                  community: widget.community,
                  communityOwner: widget.communityOwner,
                  membership: widget.membership,
                  access: accessList[index]);
            },
          );
        } else {
            log("membership_list: Snapshot Error ${snapshots.error} ... Loading()", name: "${runtimeType.toString()}:build()");
            return const Loading();
        }
      }
    );
  }
}