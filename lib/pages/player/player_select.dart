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
      // stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocQueryListStream(
      //   filterField1: "fName", filterValue1: filterFName,
      //   filterField2: "lName", filterValue2: filterLName,
      // ),
      stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocQueryListStream(
          queryValues: {'fName': filterFName, 'lName': filterLName, 'status': 1}
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
            body: ListView(
                  // itemCount: player.length,
                  // itemBuilder: (context, index) {
                  children:
                    List<Widget>.generate(1, (index) {
                      return ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () {
                            setState(() {});
                            log("Filter Pressed ... SetState() Fname: $filterFName, Lname: $filterLName");
                          },
                        ),
                        title: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                width: 130,
                                height: 40,
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                width: 130,
                                height: 40,
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
                            ),
                          ],
                        ),
                      );
                    }) +
                    List<Widget>.generate(
                    player.length,
                      (int index) {
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
                            ),
                          );
                      },
                  ),
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