import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/material.dart';

class AuditCommunityHeader extends StatelessWidget {
  final Community? community;

  const AuditCommunityHeader({super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Community: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${community?.name ?? "..."}"),
          ],
        ),
      ],
    );
  }
}
