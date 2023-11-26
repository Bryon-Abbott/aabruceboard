import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/models/messageowner.dart';
import 'package:bruceboard/pages/membership/membership_tile.dart';
//import 'package:bruceboard/services/message.dart';
import 'package:bruceboard/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';

class MembershipList extends StatefulWidget {
  const MembershipList({super.key});

  @override
  State<MembershipList> createState() => _MembershipListState();
}

class _MembershipListState extends State<MembershipList> {

  late BruceUser bruceUser;
  Community? community;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);
    Player? player;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.membership, uid: bruceUser.uid).fsDocList,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Membership> membershipList = snapshots.data!.map((s) => s as Membership).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Membership - Count: ${membershipList.length}'),
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
                      // Todo: Look at overlap of community & player.
                      Community? community;
                      Player? communityPlayer;
                      dynamic results = await Navigator.pushNamed(context, '/community-select');
                      if (results != null) {
                        communityPlayer = results[0] as Player;
                        community = results[1] as Community;
                        log("membership_list: Community Selected: ${community.name ?? 'Not Selected'}");
                        // Add Membership to current Player with "Requested" Status
                        Membership membership = Membership(
                          data: { 'cid': community.docId, // Community Owner CID
                                  'pid': communityPlayer.docId,  // Community Onwer PID
                                  'uid': communityPlayer.uid,  // Community Owner UID
                                  'status': 'Requested',
                                }
                        );
                        // Note ... the database section is the current user but the Membership PID
                        // is the PID of the owner of the community.
                        await DatabaseService(FSDocType.membership, uid: bruceUser.uid).fsDocAdd(membership);

                        log("membership_list: Updating noMemberships: ${communityPlayer.noMemberships.toString() ?? 'Didnt get memberships'}");
                        // Add MemberOwner to Community Player for current Player
                        Player? player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
                        MessageOwner msgOwner = MessageOwner( data: {
                          'docId': player.docId,
                          'uid': player.uid,  // Sending Players UID
                        } );
                        await DatabaseService(FSDocType.messageowner, toUid: communityPlayer.uid).fsDocAdd(msgOwner);
                        // Add Join Request Message to Community Player with "Requested" Status
                        Message msg = Message( data: {
                          'messageType': 1, // Community Join Request
                          'pidTo': communityPlayer.docId,
                          'pidFrom': player.docId,
                          'uid': communityPlayer.uid,  // Sending Players UID
                          'data': {'cid': community.docId, 'pid': community.pid},
                          'userMessage': 'No Comment',
                        } );
                        log('membership_lsit: Adding Message to ${communityPlayer.uid} from U: ${bruceUser.uid}');
                        await DatabaseService(FSDocType.message, toUid: communityPlayer.uid).fsDocAdd(msg);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: membershipList.length,
              itemBuilder: (context, index) {
                return MembershipTile(membership: membershipList[index]);
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