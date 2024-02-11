import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class PlayerSelect extends StatefulWidget {
  const PlayerSelect({super.key});

  @override
  State<PlayerSelect> createState() => _PlayerSelectState();
}

class _PlayerSelectState extends State<PlayerSelect> {
  String filterFName = '';
  String filterLName = '';

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    // Todo: Don't need UID, look to remove from Database
    bruceUser = Provider.of<BruceUser>(context);
    return StreamBuilder<List<FirestoreDoc>>(
      // stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocListStream,
      stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocQueryListStream(
        filterField1: "fName", filterValue1: filterFName,
        filterField2: "lName", filterValue2: filterLName,
      ),
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Player> player =  snapshots.data!.map((s) => s as Player).toList();
          return Scaffold(
            appBar: AppBar(
                title: Text('Select Player - Count: ${player.length}'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("First Name",
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'First Name',
                          ),
                          onChanged: (String value) {
                            filterFName = value;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Last Name",
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Last Name',
                          ),
                          onChanged: (String value) {
                            filterLName = value;
                          },
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.filter_alt),
                        onPressed: () {
                          setState(() {

                          });
                          log("Filter Pressed ... SetState() Fname: $filterFName, Lname: $filterLName");
                        }, )
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: ListView.builder(
                    itemCount: player.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text("${player[index].fName} ${player[index].lName}"),
                        subtitle: Text(player[index].uid),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            log('Icon Pressed', name: '${runtimeType.toString()}:ListTile:onPressed()');
                            Navigator.of(context).pop(player[index]);
                          },
                        )
                        ,
                        );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          log("player_select: Snapshot Error ... ${snapshots.error}");
          return const Loading();
        }
      }
    );
    }
}