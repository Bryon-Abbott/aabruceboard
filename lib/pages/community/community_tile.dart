
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/pages/member/member_list.dart';
import 'package:bruceboard/pages/community/community_maintain.dart';
import 'package:flutter/material.dart';

class CommunityTile extends StatelessWidget {

  final Community community;
  const CommunityTile({super.key,  required this.community });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            // log("Community Tapped ... ${community.name} ");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MemberList(community: community,)),
            );
          },
          leading: const Icon(Icons.list_alt_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Community: ${community.name}'),
          subtitle: Text('Members: ${community.noMembers}'
              ' SID: ${community.key}'
          ),
          trailing: IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CommunityMaintain(community: community)));
              },
              icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}