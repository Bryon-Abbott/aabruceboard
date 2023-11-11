import 'dart:developer';

import 'package:bruceboard/models/player.dart';
import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {

  final Player player;
  const PlayerTile({super.key,  required this.player });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
             log("Player Tapped ... ${player.fName} ");
          },
          leading: const Icon(Icons.list_alt_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Player: ${player.fName} ${player.lName}'),
          subtitle: Text('Player ID: ${player.uid}'
//              ' SID: ${player.sid}'
          ),
          trailing: IconButton(
              onPressed: (){
                log("Player Edit Pressed ... ${player.fName} ");
              },
              icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}