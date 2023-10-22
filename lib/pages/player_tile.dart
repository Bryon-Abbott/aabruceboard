import 'package:bruceboard/models/player.dart';
import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {

  final Player player;
  PlayerTile({ required this.player });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.brown,
            backgroundImage: AssetImage('assets/player.png'),
          ),
          title: Text('${player.fName} ${player.lName}'),
          subtitle: Text('Initials: ${player.initials}'),
        ),
      ),
    );
  }
}