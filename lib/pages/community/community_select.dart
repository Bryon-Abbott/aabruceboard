import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class CommunitySelect extends StatefulWidget {
  const CommunitySelect({super.key});

  @override
  State<CommunitySelect> createState() => _CommunitySelectState();
}

class _CommunitySelectState extends State<CommunitySelect> {
  //Map<String, dynamic> data =;
  Player player = Player(data: {'uid': 'Select Player', 'pid': -1, 'lName': '', 'fName': '', 'initials': 'xx'});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: const Text('Community Select'),
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
          // const Text("Player ID"),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text("Player: ${player.fName} ${player.lName}"),
            subtitle: Text("PID: ${player.pid}"),
            trailing: ElevatedButton(
                onPressed: () async {
                  dynamic playerSelected = await Navigator.pushNamed(
                      context, '/player-select');
                  if (playerSelected != null) {
                    setState((){
                      player = playerSelected as Player;
                    });
                    log('Player Selected ${player.fName}');
                  } else {
                    log("No player selected");
                  }
                },
                child: const Text("Select Player")
            ),
          ),
         // const Text("Player Communities"),
          SingleChildScrollView(
            child: SizedBox(
              height: 300,
              child: StreamBuilder<List<FirestoreDoc>>(
                stream: DatabaseService(FSDocType.community, uid: player.uid ).fsDocListStream,
                builder: (context, snapshots) {
              if(snapshots.hasData) {
                List<Community> community = snapshots.data!.map((s) => s as Community).toList();
                return Scaffold(
                  appBar: AppBar(
                      title: const Text('Select Community'),
                      centerTitle: true,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0)
                        ),
                        // if user presses back, cancels changes to list (order/deletes)
                        onPressed: null,
                      ),
                  ),
                  body: ListView.builder(
                    itemCount: community.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(community[index].name),
                        subtitle: Text("${community[index].docId}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            log('Icon Pressed', name: '${runtimeType.toString()}:ListTile:onPressed()');
                            Navigator.of(context).pop([player, community[index]]);
                          },
                        ),
                      );
                    },
                  ),
                );
              } else {
                log("community_list: Snapshot Error ${snapshots.error}");
                return const Loading();
              }
          }
    ),
            ),
//  }

  )
        ],
      ),
    );
  }
}
