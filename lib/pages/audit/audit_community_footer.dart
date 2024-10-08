import 'package:bruceboard/models/community.dart';
import 'package:flutter/material.dart';

class AuditCommunityFooter extends StatelessWidget {
  final Community community;
  const AuditCommunityFooter({super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Text("Community: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("${community.name}"),
        ]
    );
//    return Text("Footer:  ${game.name}");
  }
}
