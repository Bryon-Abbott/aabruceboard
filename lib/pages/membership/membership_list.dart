import 'dart:developer';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/pages/membership/membership_tile.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
// Todo: Implement delete

class MembershipList extends StatefulWidget {
  const MembershipList({super.key});

  @override
  State<MembershipList> createState() => _MembershipListState();
}

class _MembershipListState extends State<MembershipList> {
  late BruceUser bruceUser;
  Community? community;
  late Player activePlayer;

  @override
  Widget build(BuildContext context) {

    bruceUser = Provider.of<BruceUser>(context);
    activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.membership).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Membership> membershipList = snapshots.data!.map((s) => s as Membership).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Manage Memberships (${membershipList.length})'),
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
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    addOnPressed(context);
                    setState(() {});
                  },
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
          log("membership_list: Snapshot Error ${snapshots.error}", name: '${runtimeType.toString()}:...');
          return const Loading();
        }
      }
    );
  }
  void addOnPressed(BuildContext context) async {
    Community? community;
    Player? communityPlayer;
    if (bruceUser.emailVerified) {
      dynamic results = await Navigator.pushNamed(context, '/community-select-owner');
      if (results != null) {
        communityPlayer = results[0] as Player;
        community = results[1] as Community;
        // log('membership_list: Check if selected community already exists ... P:U:${communityPlayer.docId}:${community.docId} ');
        dynamic existingMembership = await DatabaseService(FSDocType.membership).fsDoc(
            key: Membership.KEY(communityPlayer.docId, community.docId));
        if (existingMembership == null ) { // If not found, request membership from community owner.
          // Player? player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
          // Verify Request with Player.
          if (!context.mounted) return;
          String? comment = await openDialogMessageComment(context, defaultComment: "Please add me to your <${community.name}> community.");
          log('membership_list: Comment is $comment', name: '${runtimeType.toString()}:...');
          if (comment != null ) {
            Membership membership = Membership(
                data: { 'cid': community.docId, // Community Owner CID
                  'cpid': communityPlayer.docId,  // Community Onwer PID
                  'pid': activePlayer.docId,  // Player PID
                  'status': 'Requested',
                }
            );
            // Note ... the database section is the current user but the Membership PID
            // is the PID of the owner of the community.
            await DatabaseService(FSDocType.membership).fsDocAdd(membership);
            log("membership_list: Updating MSID: ${membership.docId}", name: '${runtimeType.toString()}:...');
            // Add MemberOwner to Community Player for current Player
            // Process Messages
            await messageSend(00010, messageType[MessageTypeOption.request]!,
                playerFrom: activePlayer, playerTo: communityPlayer,
                description: '${activePlayer.fName} ${activePlayer.lName} requested to be added to your <${community.name}> community',
                comment: comment,
                data: {
                  'msid': membership.docId, // Membership ID of requesting player   // Not Required?
                  'cpid': membership.cpid,  // Community Player ID                  // Is the playerTo but include for completenesss
                  'cid': membership.cid,    // Community ID of Community Player
                  'pid': membership.pid,                                            // Not Required?
                });
          }
        } else {
          // Error: Membership request already exists ... display message
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Membership Request already exist ... delete to re-request"))
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verify Email to join Communities"))
      );
    }
  }
}