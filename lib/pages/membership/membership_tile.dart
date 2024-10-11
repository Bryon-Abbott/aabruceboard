import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/access/access_list_series.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MembershipTile extends StatelessWidget {
  final Membership membership;
  MembershipTile({super.key,  required this.membership });
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    CommunityPlayerProvider communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context);
    Player communityPlayer; // = communityPlayerProvider.communityPlayer;
    Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;

    // Set the Membership Provider to be user later.
    MembershipProvider membershipProvider = Provider.of<MembershipProvider>(context);
    Member? member;

    // Player? player;
    Community? community;

    return FutureBuilder<FirestoreDoc?>(
      future: DatabaseService(FSDocType.player).fsDoc(docId: membership.cpid),
      builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot) {
        if (snapshot.hasData) {
          communityPlayer = snapshot.data as Player;
          return FutureBuilder<FirestoreDoc?>(
            future: DatabaseService(FSDocType.community, uid: communityPlayer.uid)
                .fsDoc(docId: membership.cid),
            builder: (context, AsyncSnapshot<FirestoreDoc?> snapshot2) {
              if (snapshot2.hasData) {
                community = snapshot2.data as Community;
                return StreamBuilder<FirestoreDoc?>(
                  stream: DatabaseService(FSDocType.member, uid: communityPlayer.uid, cidKey: Community.Key(membership.cid))
                      .fsDocStream(docId: membership.pid),
                  builder: (context, snapshot3) {
                    if (snapshot3.hasData) {
                      member = snapshot3.data as Member;
                      log('Member Snapshot retrieved ${membership.key}:${member?.key ?? -98} ... ', name: '${runtimeType.toString()}:build()');
                    } else {
                      member = null;
                      log('Member Snapshot has no data ... ', name: '${runtimeType.toString()}:build()');
                    }
                    log('Member ${membership.key}:${member?.key ?? 80} Credits ${member?.credits ?? -99} ... ', name: '${runtimeType.toString()}:build()');
                    return Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 1.0),
                        child: ListTile(
                          leading: const Icon(Icons.list_alt_outlined),
                          onTap: () async {
                            log("Membership Tapped ... ${membership.cpid} ${membership.cid} ", name: '${runtimeType.toString()}:...');
                            membershipProvider.currentMembership = membership;
                            log("*** Setting Membership to ${membership.key}", name: '${runtimeType.toString()}:build()');
                            // Set the CommunityPlayerProvider
                            communityPlayerProvider.communityPlayer = communityPlayer;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AccessListSeries(membership: membership)),
                            );
                          },
                          title: Text('Community: ${community?.name ?? '...'}'), // (${membership.key})
                          subtitle: Column(
                            // mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Owner: ${communityPlayer.fName} ${communityPlayer.lName}'),
                              (community != null && community!.charity.isNotEmpty) ? Text('Charity: ${community?.charity} (${community?.charityNo})') : SizedBox(),
                              Text('Status: ${membership.status}'),
                              Text('Your Community Credits: ${member?.credits ?? 0}' ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.account_balance_outlined),
                                  padding: const EdgeInsets.all(0),
                                  //iconSize: 16,
                                  onPressed: () async {
                                    log('membership_tile: Build the Credit functionality', name: '${runtimeType.toString()}:...');
                                    dynamic results = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Add/Return Credits "),
                                        titleTextStyle: Theme.of(context).textTheme.bodyLarge,
                                        contentTextStyle: Theme.of(context).textTheme.bodyLarge,
                                        content: SizedBox(
                                          height: 300,
                                          child: Column(
                                            children: [
                                              TextField(
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
                                                autofocus: true,
                                                decoration: const InputDecoration(hintText: '99'),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                controller: controller1,
                                              ),
                                              TextField(
                                                autofocus: true,
                                                decoration: const InputDecoration(hintText: 'Message'),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                controller: controller2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop([controller1.text, controller2.text, 'credit']),
                                            child: const Text('Add'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop([controller1.text, controller2.text, 'debit']),
                                            child: const Text('Remove'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (results != null ) {
                                      log('Credits Request ${results[0]}, Message: ${results[1]}, Credit/Debit: ${results[2]} PID: ${membership.pid} CID: ${membership.cid}', name: '${runtimeType.toString()}:...');
                                      // Send Message to user
                                      // Player? communityPlayer = await DatabaseService(FSDocType.player).fsDoc(docId: membership.cpid) as Player;
                                      // Community? community = await DatabaseService(FSDocType.community, uid: communityPlayer.uid).fsDoc(docId: membership.cid) as Community;
                                      if (results[2] == 'credit') {
                                        messageSend(00020, messageType[MessageTypeOption.request]!,
                                            playerFrom: activePlayer,
                                            playerTo: communityPlayer,
                                            description: "Request to add ${results[0]} credits to membership.\n"
                                                     "Community: <${community?.name ?? "Unknown"}>\nRequester: ${activePlayer.fName} ${activePlayer.lName}",
                                            comment: results[1],
                                            data: {
                                              'credits':  int.parse(results[0]),
                                              'creditDebit': results[2],
                                              'cid': membership.cid }
                                        );
                                      } else {
                                        messageSend(00020, messageType[MessageTypeOption.request]!,
                                            playerFrom: activePlayer,
                                            playerTo: communityPlayer,
                                            description: "Request to refund ${results[0]} credits from membership.\n"
                                                     "Community: <${community?.name ?? "Unknonwn"}>\nRequester: ${activePlayer.fName} ${activePlayer.lName}",
                                            comment: results[1],
                                            data: {
                                              'credits':  int.parse(results[0]),
                                              'creditDebit': results[2],
                                              'cid': membership.cid }
                                        );
                                      }
                                    } else {
                                      log('Cancel Credit Request, PID: ${membership.pid} CID: ${membership.cid}', name: '${runtimeType.toString()}:...');
                                    }
                                    controller1.clear();
                                    controller2.clear();
                                  },
                                ),
                                // ====================
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    if (membership.status == 'Rejected' || membership.status == 'Removed') {
                                      // Delete Membership Record
                                      await DatabaseService(FSDocType.membership).fsDocDelete(membership);
                                    } else if (membership.status == 'Approved') {
                                      String? comment = await openDialogMessageComment(context, defaultComment: "Please remove me from community <${community?.name ?? "Unknown"}>");
                                      log('membership_list: Comment is $comment', name: '${runtimeType.toString()}:...');
                                      if (comment != null) {
                                        log('membership_tile: Delete Membership. Key: ${membership.key} ... $comment', name: '${runtimeType.toString()}:...');
                                        membership.status = 'Remove Requested';
                                        // Note ... the database section is the current user but the Membership PID
                                        // is the PID of the owner of the community.
                                        await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
                                        // Todo: Review the code below, could be issues if network slow and user quick ... communityPlayer can be null?
                                        messageSend(00030, messageType[MessageTypeOption.request]!,
                                          playerFrom: activePlayer,
                                          playerTo: communityPlayer,
                                          description: '${activePlayer.fName} ${activePlayer.lName} request to be removed from '
                                              'your <${community?.name ?? 'Unknown'}> community',
                                          comment: comment,
                                          data: {
                                            'msid': membership.docId,
                                            'cpid': membership.cpid,     // Community Player ID
                                            'cid': membership.cid,     // Community ID of Community Player
                                          }
                                        );
                                      }
                                    } else if (membership.status == 'Requested') {
                                      String? comment = await openDialogMessageComment( context, defaultComment: "Please remove me from community <${community?.name ?? "Unknown"}>" );
                                      log('membership_list: Comment is $comment', name: '${runtimeType.toString()}:...');
                                      if (comment != null) {
                                        log('membership_tile: Delete Membership. Key: ${membership.key} ... $comment', name: '${runtimeType.toString()}:...');
                                        membership.status = 'Removed';
                                        // Note ... the database section is the current user but the Membership PID
                                        // is the PID of the owner of the community.
                                        await DatabaseService(FSDocType.membership).fsDocUpdate(membership);
                                        // Todo: Review the code below, could be issues if network slow and user quick ... communityPlayer can be null?
                                        messageSend(00030, messageType[MessageTypeOption.request]!,
                                            playerFrom: activePlayer,
                                            playerTo: communityPlayer,
                                            description: '${activePlayer.fName} ${activePlayer.lName} request to be removed from '
                                                'your <${community?.name ?? 'Unknown'}> community',
                                            comment: comment,
                                            data: {
                                              'msid': membership.docId,
                                              'cpid': membership.cpid,     // Community Player ID
                                              'cid': membership.cid,     // Community ID of Community Player
                                              }
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text(
                                              "Membership is in an invalid status to delete"))
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    // } else {
                    //   log('membership_tile: Member Snapshot has no data ... ', name: '${runtimeType.toString()}:...');
                    //   return const Loading();
                    // }
                  }
                );
              } else {
                log('membership_tile: Community Snapshot has no data ... ', name: '${runtimeType.toString()}:...');
                return const Loading();
              }
            }
          );
        } else {
          log('membership_tile: CommunityPlayer Snapshot has no data ... ', name: '${runtimeType.toString()}:...');
          return const Loading();
        }
      }
    );
  }
}