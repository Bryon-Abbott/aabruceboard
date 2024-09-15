import 'dart:developer';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/pages/membership/membership_tile_cascade.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
class MembershipListCascade extends StatefulWidget {
  const MembershipListCascade({super.key});

  @override
  State<MembershipListCascade> createState() => _MembershipListCascadeState();
}

class _MembershipListCascadeState extends State<MembershipListCascade> {
  Player communityOwner = Player(data: {});
  Member member = Member(data: {});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FirestoreDoc>>(
//      stream: DatabaseService(FSDocType.membership).fsDocListStream,
        stream: DatabaseService(FSDocType.membership).fsDocQueryListStream(
          queryValues: {'status': "Approved"}
        ),
        builder: (context, snapshotsMembership) {
        if(snapshotsMembership.hasData) {
          List<Membership> membershipList = snapshotsMembership.data!.map((s) => s as Membership).toList();
            return ListView.builder(
              itemCount: membershipList.length,
              itemBuilder: (context, index) {
                return FutureBuilder<FirestoreDoc?>(
                  future: DatabaseService(FSDocType.player).fsDoc(docId: membershipList[index].cpid),
                  builder: (context, snapshotPlayer) {
                    if (snapshotPlayer.hasData) {
                      communityOwner = snapshotPlayer.data as Player;
                    }
                    return FutureBuilder<FirestoreDoc?>(
                      future: DatabaseService(FSDocType.community, uid: communityOwner.uid).fsDoc(docId: membershipList[index].cid),
                      builder: (context, snapshotCommunity) {
                        Community community = Community(data: {});
                        if (snapshotCommunity.hasData) {
                          community = snapshotCommunity.data as Community;
                        }
                        return StreamBuilder<FirestoreDoc?>(
                          stream: DatabaseService(FSDocType.member, uid: communityOwner.uid, cidKey: Community.Key(membershipList[index].cid)).fsDocStream(docId: membershipList[index].pid),
                          builder: (context, snapshotMember) {
                            if (snapshotMember.hasData) {
                              member = snapshotMember.data as Member;
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
//                                Text("Membership: ${index+1} of ${membershipList.length}"),
                                MembershipTileCascade(
                                  membership: membershipList[index],
                                  communityOwner: communityOwner,
                                  community: community,
                                  member: member,
                                ),
                              ],
                            );
                          }
                        );
                      }
                    );
                  }
                );
              },
            );
        } else {
          log("membership_list: Snapshot Error ${snapshotsMembership.error}", name: '${runtimeType.toString()}:...');
          return const Loading();
        }
      }
    );
  }
}