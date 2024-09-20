import 'package:bruceboard/models/game.dart';
import 'package:flutter/material.dart';

class AuditGameFooter extends StatelessWidget {
  final Game game;
  const AuditGameFooter({super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Footer:  ${game.name}");
  }
}
