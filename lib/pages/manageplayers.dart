import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'package:bruceboard/utils/brucearguments.dart';
import 'package:bruceboard/utils/players.dart';
import 'package:bruceboard/utils/games.dart';
// ==========
// Desc: Create PickPlayers() class to enter players.
// ----------
// 2023/07/20 Bryon   Created
// ==========
class ManagePlayers extends StatefulWidget {
  const ManagePlayers({super.key});

  @override
  State<ManagePlayers> createState() => _ManagePlayersState();
}

class _ManagePlayersState extends State<ManagePlayers> {
  late BruceArguments args;
  late Games games;
  late Players players;
  late double screenWidth, screenHeight, newScreenHeight, newScreenWidth;

  int counter = 0;
  bool playerListChanged = false;
  final double iconSize = 24;

  @override
  void initState() {
    players = Players();
    games = Games();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as BruceArguments;
//    players = args.players;
//    players = Players();
//    games = args.games;
//    games = Games();

    // Calculate screen size
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    newScreenHeight = screenHeight - padding.top - padding.bottom;
    newScreenWidth = screenWidth - padding.left - padding.right;
    dev.log("Screen Dimensions are Height: $screenHeight, Width: $screenWidth : Height: $newScreenHeight, Width: $newScreenWidth", name: " ${this.runtimeType.toString()}:build");

    //print('Build function ran');
    return Scaffold(
//      backgroundColor: Colors.grey[200],
      appBar: AppBar(
//          backgroundColor: Colors.blue[900],
          title: const Text('Manage Players'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            // if user presses back, cancels changes to list (order/deletes)
            onPressed: () {
              if(playerListChanged) {
                players.loadPlayers();
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  players.currentPlayer = -1; // No current player
                  dynamic changes = await Navigator.pushNamed(
//                      context, '/maintainplayer', arguments: players);
                      context, '/maintainplayer');
                  if (changes != null && changes == true) {
                  // if (changes) {
                    setState(() {
                      //players.savePlayers();
                    });
                  }
                },
                icon: const Icon(Icons.person_add)
            )
          ]),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: players.players.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                  child: Row(
                      children: [
                        //Icon(Icons.person_outline, size: 32),
                        //const CircleAvatar(backgroundImage: AssetImage('assets/player.png')),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: SizedBox(
                            width: max(120, newScreenWidth-260),
                            height: 50,
                            child: Text("${players.getPlayer(index).lName} (${players.getPlayer(index).playerNo.toString()})",
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: SizedBox(
                            width: 240,
                            height: 50,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      // Save player list if changes.
                                      if (playerListChanged) {
                                        players.savePlayers();
                                      }
                                      // return with selected user
                                      // Todo: Need to look at impact of changes to list before returning
                                      // Should return playerNo
                                      Navigator.of(context).pop(players.getPlayer(index)); // Return selected player
                                    },
                                    icon: Icon(Icons.copy, size: iconSize)),
                                IconButton(
                                    onPressed: () async {
                                      players.currentPlayer = index;
                                      dynamic changes = await Navigator.pushNamed(
                                          // context, '/maintainplayer', arguments: players);
                                          context, '/maintainplayer');
                                      if (changes) {
                                        setState(() {
                                          //players.savePlayers();
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.edit, size: iconSize)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        playerListChanged = true;
                                        players.moveup(index);
                                      });
                                    },
                                    icon: Icon(Icons.arrow_upward, size: iconSize)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        playerListChanged = true;
                                        players.movedown(index);
                                      });
                                    },
                                    icon: Icon(Icons.arrow_downward, size: iconSize)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        playerListChanged = true;
                                        players.delPlayer(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete, size: iconSize)),
                              ]
                            ),
                          ),
                        ),
                      ]),
                );
              },
            ),
          ),
          ButtonBar(
            buttonMinWidth: 200.0,
            alignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                // Save list if any changes (ie order/deletes)
                onPressed: () {
                  if (playerListChanged) {
                    players.savePlayers();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Save")),
              ElevatedButton(
                // if user presses back, cancels changes to list (order/deletes)
                onPressed: () {
                  if(playerListChanged) {
                    players.loadPlayers();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel")),
            ]
          )
        ],
      ),
    );
  }
}
