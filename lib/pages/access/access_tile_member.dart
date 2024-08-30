import 'dart:developer';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';

class AccessTileMembers extends StatelessWidget {
  final Access access;
  const AccessTileMembers({super.key,  required this.access });

  @override
  Widget build(BuildContext context) {
//    BruceUser bruceUser = Provider.of<BruceUser>(context);

    final Player communityPlayer = Provider.of<CommunityPlayerProvider>(context).communityPlayer;
    // String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ?? "-1";
    // int excludePlayerNo = int.parse(excludePlayerNoString);
    log("Got Exclude PID ($kExcludePlayerNo)", name: "${runtimeType.toString()}:onMenuSelected");

//    Community? community;

    return FutureBuilder<FirestoreDoc?>(
      future: DatabaseService(FSDocType.community, uid: communityPlayer.uid, cidKey: Community.Key(access.cid))
        .fsDoc(docId: access.cid),
      builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
        if (snapshot.hasData) {
          Community community = snapshot.data as Community;
          return FutureBuilder<List<FirestoreDoc?>>(
            future: DatabaseService(FSDocType.member, uid: communityPlayer.uid, cidKey: Community.Key(access.cid))
                .fsDocList,
            builder: (context, AsyncSnapshot<List<FirestoreDoc?>> snapshots) {
              if (snapshots.hasData) {
                List<Member> memberList = snapshots.data!.map((
                    m) => m as Member).toList();
                return Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                    child:
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                          List<Widget>.generate(1, (index) {
                            return Text("Community: ${community.name}");
                          }) +
                          List<Widget>.generate(memberList.length, (index) {
                            return FutureBuilder<FirestoreDoc?>(
                              future: DatabaseService(FSDocType.player).fsDoc(docId: memberList[index].docId),
                              builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
                                Player? player;
                                if (snapshot.hasData) {
                                  player = snapshot.data as Player;
                                }
                                return Row(
                                  children: [
                                    Text("  Member: ${memberList[index].docId} ${player?.fName ?? '...'} ${player?.lName ?? ''} Credits: ${memberList[index].credits} "),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_outline),
                                      onPressed: ((memberList[index].credits > 0) || (memberList[index].docId == kExcludePlayerNo)) ?  () {
                                        log('Pressed. ${player?.docId ?? 0}', name: '${runtimeType.toString()}:build()');
                                        Navigator.of(context).pop([access, player]);  // Return with Access & Player
                                        } : null,
                                    )
                                  ],
                                );
                              }
                            );
                          }),
                      ),
                    ),
                  ),
                );
              } else {
                log('membership_tile: CommunityPlayer Snapshot has no data ... ');
                return const Loading();
              }
            }
          );
        } else {
          log('membership_tile: CommunityPlayer Snapshot has no data ... ');
          return const Loading();
        }
      }
    );
  }
}