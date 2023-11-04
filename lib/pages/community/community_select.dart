import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/community/community_tile.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class CommunitySelect extends StatefulWidget {
  const CommunitySelect({super.key});

  @override
  State<CommunitySelect> createState() => _CommunitySelectState();
}

class _CommunitySelectState extends State<CommunitySelect> {
  Player player = Player(uid: 'Select Player', pid: -1, lName: '', fName: '', initials: 'xx');

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text('Community Select'),
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
          Text("Player ID"),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text("Player: ${player.fName} ${player.lName}"),
            subtitle: Text("PID: ${player.uid}"),
            trailing: ElevatedButton(
                onPressed: () async {
                  dynamic playerSelected = await Navigator.pushNamed(
                      context, '/player-select');
                  if (playerSelected != null) {
                    player = playerSelected as Player;
                    setState((){});
                    log('Player Selected ${player.fName}');
                  } else {
                    log("No player selected");
                  }
                },
                child: Text("Select Player")
            )
            ,
          ),
          Text("Player Communities"),
          SingleChildScrollView(
            child: SizedBox(
              height: 300,
              child: StreamBuilder<List<Community>>(
                stream: DatabaseService(uid: player.uid).communityList,
                builder: (context, snapshots) {
              if(snapshots.hasData) {
                List<Community> community = snapshots.data!;
                return Scaffold(
                  appBar: AppBar(
                    //            backgroundColor: Colors.blue[900],
                      title: Text('Select Community'),
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
                        leading: Icon(Icons.person_outline),
                        title: Text("${community[index].name}"),
                        subtitle: Text("${community[index].cid}"),
                        trailing: IconButton(
                          icon: Icon(Icons.check_circle_outline),
                          onPressed: () {
                            log('Icon Pressed');
                            Navigator.of(context).pop(community[index]);
                          },
                        )
                        ,
                      );
                      // return CommunityTile(community: community[index]);
                    },
                  ),
                );
              } else {
                log("community_list: Snapshot Error ${snapshots.error}");
                return Loading();
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
