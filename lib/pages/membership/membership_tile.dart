import 'dart:developer';

import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/services/database.dart';
import 'package:flutter/material.dart';

class MembershipTile extends StatelessWidget {

  final Membership membership;
  const MembershipTile({super.key,  required this.membership });

  @override
  Widget build(BuildContext context) {

    // Community? community;
    // Player? player;

    // Override the UID to get community from given player vs signed on player.
    // community = DatabaseService(uid: membership.pid, cid: membership.cid).community;
    // if (community != null){
    //   player = DatabaseService(uid: community.pid).player;
    // }
    // log('membership_tile: Got Community & Player ${community?.name ?? 'Error'} ${player?.fName ?? 'Error'} ');

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            log("Membership Tapped ... ${membership.cid} ");
          },
          leading: const Icon(Icons.list_alt_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Membership Status: ${membership.status}'),
          subtitle: Text('Community: ${membership.key}'
//              ' SID: ${membership.sid}'
          ),
          trailing: IconButton(
            onPressed: (){
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => MembershipMaintain(membership: membership)));
              log('membership_tile: Delete Membership. Key: ${membership.key}');
              DatabaseService(membership).fsDocDelete();
              },
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}