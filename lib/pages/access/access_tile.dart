import 'dart:developer';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';

class AccessTile extends StatelessWidget {
  final Access access;
  const AccessTile({super.key,  required this.access });

  @override
  Widget build(BuildContext context) {
//    BruceUser bruceUser = Provider.of<BruceUser>(context);

    // Player communityPlayer = DatabaseService(FSDocType.player).fsDoc(docId: membership.pid) as Player;
    // Community community = DatabaseService(FSDocType.community, uid: communityPlayer.uid)
    //     .fsDoc(docId: membership.cid) as Community;
    Player? communityPlayer2;
    Community? community2;

    return FutureBuilder<FirestoreDoc?>(
      future: DatabaseService(FSDocType.player).fsDoc(docId: access.pid),
      builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
        if (snapshot.hasData) {
          communityPlayer2 = snapshot.data as Player;
        } else {
          log('membership_tile: CommunityPlayer Snapshot has no data ... ');
        }
        return FutureBuilder<FirestoreDoc?>(
            future: DatabaseService(FSDocType.community, uid: communityPlayer2?.uid ?? "xxx").fsDoc(docId: access.cid),
            builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot2) {
              if (snapshot2.hasData) {
                community2 = snapshot2.data as Community;
              } else {
                log('membership_tile: CommunityPlayer Snapshot has no data ... ');
              }
              return Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Card(
                  margin: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 1.0),
                  child: ListTile(
                    onTap: () {
                      log("Membership Tapped ... ${access.cid} ");
                    },
                    leading: const Icon(Icons.key_outlined),
                    title: Text('Membership Type: ${access.type}'),
                    subtitle: Text(
                      'Community: ${community2?.name ?? '...'} (${access.key})\n'
                      'Owner: ${communityPlayer2?.fName ?? "..."} ${communityPlayer2?.lName ?? ""}'),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                            //iconSize: 16,
                            onPressed: () async {
                              // TOdo: Need to find Series we are in.
                              await DatabaseService(FSDocType.access, sidKey: Series.Key(access.sid)).fsDocDelete(access);
                              // Todo: What happens when I delete?
                              log('access_tile: Deleting ');
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
        );
    }
    );
  }
}