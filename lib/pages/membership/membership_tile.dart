import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipTile extends StatelessWidget {
  final Membership membership;
  MembershipTile({super.key,  required this.membership });

  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            log("Membership Tapped ... ${membership.cid} ");
          },
          leading: const Icon(Icons.list_alt_outlined),
          title: Text('Membership Status: ${membership.status}'),
          subtitle: Text('Community: ${membership.key}'),
          trailing: IconButton(
            onPressed: () async {
              // Todo: Check status to determine what happens
              // Approved -> Delete
              // Requested --> Update "Rejected'
              // Remove Requested --> block?
              if (membership.status == 'Rejected') {
                await DatabaseService(FSDocType.membership).fsDocDelete(membership);
              } else if (membership.status == 'Approved') {
                Player? player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
                Player? communityPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: membership.pid) as Player;
                Community? community = await DatabaseService(FSDocType.community, uid: communityPlayer.uid)
                    .fsDoc( docId: membership.cid ) as Community;
                // Navigator.of(context).push(
                //     MaterialPageRoute(builder: (context) => MembershipMaintain(membership: membership)));
                String? comment = await openDialogMessageComment(context);
                log('membership_list: Comment is ${comment}');
                if (comment != null ) {
                  log('membership_tile: Delete Membership. Key: ${membership.key} ... ${comment}');
                  membership.status ='Remove Rrequested';
                  // Note ... the database section is the current user but the Membership PID
                  // is the PID of the owner of the community.
                  await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
                  await messageMembershipRemoveRequest(membership: membership, player: player, communityPlayer: communityPlayer,
                      description: '${player.fName} ${player.lName} request to be removed from your <${community.name}> community',
                      comment: comment);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Membership is in an invalid status to delete"))
                );
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}