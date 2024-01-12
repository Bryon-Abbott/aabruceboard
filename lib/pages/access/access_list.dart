import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/pages/access/access_tile.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
// Todo: Implement delete

class AccessList extends StatefulWidget {
  final Series series;
  const AccessList( {super.key, required this.series} );

  @override
  State<AccessList> createState() => _AccessListState();
}

class _AccessListState extends State<AccessList> {
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
                title: Text('Manage Access - Series: ${series.name}'),
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
                      Community? community;
                      Player? communityPlayer;
                      dynamic results = await Navigator.pushNamed(context, '/community-select');
                      if (results != null) {
                        communityPlayer = results[0] as Player;
                        community = results[1] as Community;
                        // log('membership_list: Check if selected community already exists ... P:U:${communityPlayer.docId}:${community.docId} ');
                        dynamic existingAccess = await DatabaseService(FSDocType.access, sidKey: series.key).fsDoc(
                            key: Access.KEY(communityPlayer.docId, community.docId));
                        if (existingAccess == null ) { // If not found, request membership from community owner.
                          Player? player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
                          // Verify Request with Player.
                            Access access = Access( data: {
                                'cid': community.docId, // Community Owner CID
                                'pid': communityPlayer.docId,  // Community Onwer PID
                                'sid': series.docId,
                                'type': 'Active',
                              });
                            // Note ... the database section is the current user but the Membership PID
                            // is the PID of the owner of the community.
                            await DatabaseService(FSDocType.access, sidKey: series.key).fsDocAdd(access);
                            series.noAccesses++;
                            log("access_list: Updating AID: ${access.docId ?? -600}");
                            // Add MemberOwner to Community Player for current Player
                            // Process Messages
                            // await messageMembershipAddRequest(membership: membership, player: player, communityPlayer: communityPlayer,
                            //     description: '${player.fName} ${player.lName} requested to be added to your <${community.name}> community',
                            //     comment: comment);
                        } else {
                          // Error: Membership request already exists ... display message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Access already exist ... "))
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: accessList.length,
              itemBuilder: (context, index) {
                return AccessTile(access: accessList[index]);
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