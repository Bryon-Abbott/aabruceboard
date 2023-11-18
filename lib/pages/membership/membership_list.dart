import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/message.dart';
import 'package:bruceboard/pages/membership/membership_tile.dart';
import 'package:bruceboard/services/message.dart';
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

    return StreamBuilder<List<Membership>>(
      stream: DatabaseService(Membership(data: {}), uid: bruceUser.uid).fsDocList as Stream<List<Membership>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Membership> membershipList = snapshots.data!;
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
                      Player? player;
                      dynamic results = await Navigator.pushNamed(context, '/community-select');
                      if (results != null) {
                        player = results[0] as Player;
                        community = results[1] as Community;
                        log("membership_list: Community Selected: ${community.name ?? 'Not Selected'}");
                        Map<String, dynamic> data =
                        {
                          'cid': community.cid,
                          'pid': player.pid,  // Community Onwer PID
                          'uid': player.uid,  // Community Owner UID
                          'status': 'Requested',
                        };
                        Membership membership = Membership(data: data);
                        // Note ... the database section is the current user but the Membership PID
                        // is the PID of the owner of the community.
                        await DatabaseService(membership, uid: bruceUser.uid).fsDocAdd();
                        log("membership_list: Updating noMemberships: ${player.noMemberships.toString() ?? 'Didnt get memberships'}");
                        Message msg = Message(data: { } );

                        await MessageService(msg).fsDocAdd();
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