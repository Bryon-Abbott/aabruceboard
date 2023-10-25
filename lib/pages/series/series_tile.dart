import 'dart:developer';

import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_list.dart';
import 'package:bruceboard/pages/series/series_maintain.dart';
import 'package:flutter/material.dart';

class SeriesTile extends StatelessWidget {

  final Series series;
  SeriesTile({ required this.series });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            // log("Series Tapped ... ${series.name} ");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => GameList(series: series)),
            );
          },
          leading: Icon(Icons.list_alt_outlined),
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.brown,
          //   backgroundImage: AssetImage('assets/player.png'),
          // ),
          title: Text('Series: ${series.name}'),
          subtitle: Text('Number of Games: ${series.noGames}'
              ' CID: ${series.sid}'),
          trailing: IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SeriesMaintain(series: series)));
              },
              icon: Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}