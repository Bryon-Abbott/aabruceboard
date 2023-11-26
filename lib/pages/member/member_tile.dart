import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/member/member_maintain.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  final Community community;
  final Member member;
  final Function callback;

  const MemberTile({super.key,  required this.callback, required this.community, required this.member });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirestoreDoc>(
      stream: DatabaseService(FSDocType.player).fsDocStream(docId: member.docId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Player memberPlayer = snapshot.data as Player;
          return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Card(
                margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                child: ListTile(
                  onTap: ()  {
                    log("Member Tapped ... ${member.credits} : ${member.docId} ");
                  },
                  leading: const Icon(Icons.sports_football_outlined),
                  title: Text('Member: ${memberPlayer.fName ?? "Error"} ${memberPlayer.lName ?? "Error"}'),
                  subtitle: Text(' MID: ${member.docId} CID: ${community.docId}'),
                  trailing: IconButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MemberMaintain(community: community, member: member)));
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ),
            );
        } else {
          log("member_tile: Snapshot Error ${snapshot.error}");
          return const Loading();
        }
      });
  }
}