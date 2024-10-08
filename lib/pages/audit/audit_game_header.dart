import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/material.dart';

class AuditGameHeader extends StatelessWidget {
  final Game game;
  final Community? community;
  final Series? series;

  const AuditGameHeader({super.key,
    required this.game,
    required this.community,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Community: ", style: Theme.of(context).textTheme.titleSmall,),
            Text("${community?.name ?? "..."}"),
          ],
        ),
        Row(
          children: [
            Text("Group: ", style: Theme.of(context).textTheme.titleSmall,),
            Text("${series?.name ?? "..."}"),
          ],
        ),
        Row(
          children: [
            Text("Game: ", style: Theme.of(context).textTheme.titleSmall,),
            Text("${game.name}"),
          ],
        ),
      ],
    );
  }
}
