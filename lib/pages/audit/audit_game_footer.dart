import 'package:bruceboard/models/game.dart';
import 'package:flutter/material.dart';

class AuditGameFooter extends StatelessWidget {
  final Game game;
  const AuditGameFooter({super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Text("Game: ", style: Theme.of(context).textTheme.titleSmall,),
          Text(game.name),
        ]
    );
//    return Text("Footer:  ${game.name}");
  }
}
