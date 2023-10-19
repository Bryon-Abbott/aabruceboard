import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:bruceboard/utils/brucearguments.dart';
import 'package:bruceboard/utils/games.dart';
import 'package:bruceboard/utils/players.dart';
// ==========
// Desc: Create PickGames() class to enter games.
// ----------
// 2023/09/14 Bryon   Created
// ==========
class ManageGames extends StatefulWidget {
  const ManageGames({super.key});

  @override
  State<ManageGames> createState() => _ManageGamesState();
}

class _ManageGamesState extends State<ManageGames> {
  late BruceArguments args;
  late Games games;
  late Players players;
  late double screenWidth, screenHeight, newScreenHeight, newScreenWidth;

  int counter = 0;
  bool gameListChanged = false;
  final double iconSize = 24;

  @override
  Widget build(BuildContext context) {
    //activeGames = ModalRoute.of(context)!.settings.arguments as Games;
    args = ModalRoute.of(context)!.settings.arguments as BruceArguments;
    players = args.players;
    games = args.games;

    // Calculate screen size
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    newScreenHeight = screenHeight - padding.top - padding.bottom;
    newScreenWidth = screenWidth - padding.left - padding.right;
    dev.log("Screen Dimensions are Height: $screenHeight, Width: $screenWidth : Height: $newScreenHeight, Width: $newScreenWidth", name: " ${this.runtimeType.toString()}:build");


    //print('Build function ran');
    return SafeArea(
      child: Scaffold(
//        backgroundColor: Colors.grey[200],
        appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: const Text('Manage Games'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // if user presses back, cancels changes to list (order/deletes)
              onPressed: () {
                if(gameListChanged) {
                  games.loadGames();
                }
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    games.currentGame = -1; // No current game
                    dynamic changes = await Navigator.pushNamed(
                        context, '/maintaingame');
                    if (changes != null && changes == true) {
                    // if (changes) {
                      setState(() {
                        //games.saveGames();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
              )
            ]),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: games.games.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //  crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //const CircleAvatar(backgroundImage: AssetImage('assets/player.png')),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(Icons.sports_football_outlined)
                          // ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2,2,2,2),
                            child: SizedBox(
                              width: max(120, newScreenWidth-260),
                              height: 50,
                              child: Text("${games.getGame(index).name} (${games.getGame(index).gameNo.toString()})",
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
                              width: 250,
                              height: 50,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        // Save game list if changes.
                                        if (gameListChanged) {
                                          games.saveGames();
                                        }
                                        // return with selected user
                                        // Todo: Need to look at impact of changes to list before going to GameBoard
                                        // Should return gameNo
                                        games.currentGame = index;
                                        Navigator.pushNamed(context, '/gameboard', arguments: BruceArguments(players, games));
                                      },
                                      icon: Icon(Icons.sports_football_outlined, size: iconSize)),
                                  IconButton(
                                      onPressed: () async {
                                        games.currentGame = index;
                                        dynamic changes = await Navigator.pushNamed(
                                            context, '/maintaingame');
                                        if (changes) {
                                          setState(() {
                                            //games.saveGames();
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.edit, size: iconSize)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          gameListChanged = true;
                                          games.moveup(index);
                                        });
                                      },
                                      icon: Icon(Icons.arrow_upward, size: iconSize)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          gameListChanged = true;
                                          games.movedown(index);
                                        });
                                      },
                                      icon: Icon(Icons.arrow_downward, size: iconSize)),
                                  IconButton(
                                      padding: const EdgeInsets.all(2),
                                      onPressed: () {
                                        setState(() {
                                          gameListChanged = true;
                                          games.delGame(index);
                                        });
                                      },
                                      icon: Icon(Icons.delete, size: iconSize)),
                                ]
                              ),
                            ),
                          )
                        ]),
                  );
                },
              ),
            ),
            ButtonBar(buttonMinWidth: 200.0, alignment: MainAxisAlignment.start,
              children: [
              ElevatedButton(
                  // Save list if any changes (ie order/deletes)
                  onPressed: () {
                    if (gameListChanged) {
                      games.saveGames();
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save")),
              ElevatedButton(
                // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    if(gameListChanged) {
                      games.loadGames();
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
            ])
          ],
        ),
      ),
    );
  }
}
