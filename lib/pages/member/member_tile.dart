import 'dart:developer';

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

  MemberTile({ required this.callback, required this.community, required this.member });

  @override
  Widget build(BuildContext context) {

    Player? player = DatabaseService(uid: member.pid).player;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: ()  {
            log("Member Tapped ... ${member.pid} ");
          },
          leading: Icon(Icons.sports_football_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Member: ${player?.fName ?? "Error"} ${player?.lName ?? "Error"}'),
          subtitle: Text(' SID: ${member.cid} GID: ${member.pid}'),
          trailing: IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MemberMaintain(community: community, member: member)));
            },
            icon: Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}