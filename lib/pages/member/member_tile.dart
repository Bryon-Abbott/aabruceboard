import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/member/member_maintain.dart';
import 'package:bruceboard/services/database.dart';
import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  final Community community;
  final Member member;
  final Function callback;

  const MemberTile({super.key,  required this.callback, required this.community, required this.member });

  @override
  Widget build(BuildContext context) {

    Player? player = DatabaseService(FSDocType.player, uid: member.uid).fsDoc(key: member.uid) as Player;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: ()  {
            log("Member Tapped ... ${member.uid} : ${member.mid} ");
          },
          leading: const Icon(Icons.sports_football_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Member: ${player.fName ?? "Error"} ${player.lName ?? "Error"}'),
          subtitle: Text(' MID: ${member.mid} CID: ${community.cid}'),
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
  }
}