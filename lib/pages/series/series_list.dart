import 'dart:developer';

import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/series/series_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';

class SeriesList extends StatefulWidget {
  const SeriesList({super.key});

  @override
  _SeriesListState createState() => _SeriesListState();
}

class _SeriesListState extends State<SeriesList> {
  @override
  Widget build(BuildContext context) {

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<Series>>(
      stream: DatabaseService(pid: bruceUser.uid).seriesList,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Series> series = snapshots.data!;
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Series : ${bruceUser.displayName}'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      dynamic changes = await Navigator.pushNamed(
                          context, '/series-maintain');
                     // log('Changes Type : ${changes.runtimeType}');
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  )
                ]),
            body: ListView.builder(
              itemCount: series.length,
              itemBuilder: (context, index) {
                return SeriesTile(series: series[index]);
              },
            ),
          );
        } else {
          return Loading();
        }
      }
    );
    }
  }