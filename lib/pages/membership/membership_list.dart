import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/pages/membership/membership_tile.dart';
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
    Player? player = null;
    // Player player = DatabaseService().player;
    // if (player != null) {
    //   log('Player is ${player.fName}, ${player.noMemberships} ');
    // } else {
    //   log('Player is Null');
    // }

    return StreamBuilder<List<Membership>>(
      stream: DatabaseService(uid: bruceUser.uid).membershipList,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Membership> membership = snapshots.data!;
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Membership - Count: ${membership.length}'),
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
                      dynamic results = await Navigator.pushNamed(context, '/community-select');
                      if (results != null) {
                        community = results as Community;
                        log("membership_list: Community Selected: ${community?.name ?? 'Not Selected'}");
                        await DatabaseService(cid: community?.cid ?? 'Error').addMembership(
                          pid: community?.pid ?? 'Error',
                          status: "Requested",
                        );
                        log("membership_list: Updating noMemberships: ${player?.noMemberships.toString() ?? 'Didnt get memberships'}");
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: membership.length,
              itemBuilder: (context, index) {
                return MembershipTile(membership: membership[index]);
              },
            ),
          );
        } else {
          log("membership_list: Snapshot Error ${snapshots.error}");
          return Loading();
        }
      }
    );
    }
  }