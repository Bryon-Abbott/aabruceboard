import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';

class PlayerSelect extends StatefulWidget {
  const PlayerSelect({super.key});

  @override
  State<PlayerSelect> createState() => _PlayerSelectState();
}

class _PlayerSelectState extends State<PlayerSelect> {

  late BruceUser bruceUser;

  @override
  Widget build(BuildContext context) {

    // Todo: Don't need UID, look to remove from Database
    bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocList,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Player> player =  snapshots.data!.map((s) => s as Player).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
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
            body: ListView.builder(
              itemCount: player.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text("${player[index].fName} ${player[index].lName}"),
                  subtitle: Text(player[index].uid),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      log('Icon Pressed');
                      Navigator.of(context).pop(player[index]);
                    },
                  )
                  ,
                  );
              },
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