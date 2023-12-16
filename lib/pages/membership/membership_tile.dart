import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipTile extends StatelessWidget {
  final Membership membership;
  const MembershipTile({super.key,  required this.membership });


  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    Member? member;
    // Player communityPlayer = DatabaseService(FSDocType.player).fsDoc(docId: membership.pid) as Player;
    // Community community = DatabaseService(FSDocType.community, uid: communityPlayer.uid)
    //     .fsDoc(docId: membership.cid) as Community;
    Player? communityPlayer;
    Community? community;

    return FutureBuilder<FirestoreDoc?>(
      future: DatabaseService(FSDocType.player).fsDoc(docId: membership.pid),
      builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
        if (snapshot.hasData) {
          communityPlayer = snapshot.data as Player;
        } else {
          log('membership_tile: CommunityPlayer Snapshot has no data ... ');
        }
        return FutureBuilder<FirestoreDoc?>(
          future: DatabaseService(FSDocType.community, uid: communityPlayer?.uid ?? "xxx").fsDoc(docId: membership.cid),
          builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot2) {
            if (snapshot2.hasData) {
              community = snapshot2.data as Community;
            } else {
              log('membership_tile: CommunityPlayer Snapshot has no data ... ');
            }
            return FutureBuilder<FirestoreDoc?>(
                future: DatabaseService(FSDocType.member, uid: communityPlayer?.uid ?? "xxx", cidKey: Community.Key(membership.cid)).fsDoc(docId: membership.pid),
                builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot3) {
                  if (snapshot2.hasData) {
                    member = snapshot3.data as Member;
                  } else {
                    log('membership_tile: member Snapshot has no data ... ');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Card(
                      margin: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 1.0),
                      child: ListTile(
                        onTap: () {
                          log("Membership Tapped ... ${membership.cid} ");
                        },
                        leading: const Icon(Icons.list_alt_outlined),
                        title: Text('Membership Status: ${membership.status}'),
                        subtitle: Text(
                            'Community: ${community?.name ??
                                '...'} (${membership.key})\n'
                                'Owner: ${communityPlayer?.fName ??
                                "..."} ${communityPlayer?.lName ?? ""}'),
                        trailing: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                //iconSize: 16,
                                onPressed: () {
                                  log(
                                      'membership_tile: Build the Credit functionality');
                                },
                                icon: const Icon(Icons.attach_money_outlined),
                              ),
                              IconButton(
                                //iconSize: 16,
                                onPressed: () async {
                                  // Todo: Check status to determine what happens
                                  // Approved -> Delete
                                  // Requested --> Update "Rejected'
                                  // Remove Requested --> block?
                                  if (membership.status == 'Rejected' ||
                                      membership.status == 'Removed') {
                                    await DatabaseService(FSDocType.membership)
                                        .fsDocDelete(membership);
                                  } else if (membership.status == 'Approved') {
                                    Player? player = await DatabaseService(
                                        FSDocType.player).fsDoc(
                                        key: bruceUser.uid) as Player;
                                    // Player? communityPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: membership.pid) as Player;
                                    // Community? community = await DatabaseService(FSDocType.community, uid: communityPlayer.uid)
                                    //    .fsDoc( docId: membership.cid ) as Community;
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(builder: (context) => MembershipMaintain(membership: membership)));
                                    String? comment = await openDialogMessageComment(
                                        context);
                                    log('membership_list: Comment is $comment');
                                    if (comment != null) {
                                      log(
                                          'membership_tile: Delete Membership. Key: ${membership
                                              .key} ... $comment');
                                      membership.status = 'Remove Requested';
                                      // Note ... the database section is the current user but the Membership PID
                                      // is the PID of the owner of the community.
                                      await DatabaseService(
                                          FSDocType.membership).fsDocUpdate(
                                          membership);
                                      // Todo: Review the code below, could be issues if network slow and user quick ... communityPlayer can be null?
                                      await messageMembershipRemoveRequest(
                                          membership: membership,
                                          player: player,
                                          communityPlayer: communityPlayer!,
                                          description: '${player.fName} ${player
                                              .lName} request to be removed from your <${community
                                              ?.name ?? "Unknown"}> community',
                                          comment: comment);
                                    }
                                  } else if (membership.status == 'Requested') {
                                    Player? player = await DatabaseService(
                                        FSDocType.player).fsDoc(
                                        key: bruceUser.uid) as Player;
                                    // Player? communityPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: membership.pid) as Player;
                                    // Community? community = await DatabaseService(FSDocType.community, uid: communityPlayer.uid)
                                    //    .fsDoc( docId: membership.cid ) as Community;
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(builder: (context) => MembershipMaintain(membership: membership)));
                                    String? comment = await openDialogMessageComment(
                                        context);
                                    log('membership_list: Comment is $comment');
                                    if (comment != null) {
                                      log(
                                          'membership_tile: Delete Membership. Key: ${membership
                                              .key} ... $comment');
                                      membership.status = 'Removed';
                                      // Note ... the database section is the current user but the Membership PID
                                      // is the PID of the owner of the community.
                                      await DatabaseService(
                                          FSDocType.membership).fsDocUpdate(
                                          membership);
                                      // Todo: Review the code below, could be issues if network slow and user quick ... communityPlayer can be null?
                                      await messageMembershipRemoveRequest(
                                          membership: membership,
                                          player: player,
                                          communityPlayer: communityPlayer!,
                                          description: '${player.fName} ${player
                                              .lName} request to be removed from your <${community
                                              ?.name ?? 'Unknown'}> community',
                                          comment: comment);
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text(
                                            "Membership is in an invalid status to delete"))
                                    );
                                  }
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
    );
  }
}