import 'package:bruceboard/menus/popupmenubutton_status.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_list.dart';
import 'package:bruceboard/pages/series/series_maintain.dart';
import 'package:flutter/material.dart';

class SeriesTile extends StatelessWidget {

  final Series series;
  const SeriesTile({ super.key,  required this.series });

  @override
  Widget build(BuildContext context) {
    StatusValues status = StatusValues.values[series.status];

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(

          onTap: () {
            // log("Series Tapped ... ${series.name} ");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => GameList(series: series)),
            );
          },
          leading: const Icon(Icons.list_alt_outlined),
          title: Text('Group: ${series.name}'),
          subtitle: Row(
            children: [
              Text('Type: ${series.type} '),
              Spacer(),
              Text('${status.name}'),
            ],
          ),
          trailing: IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SeriesMaintain(series: series)));
              },
              icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}