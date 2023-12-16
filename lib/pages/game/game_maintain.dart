import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
// Todo: Look at provider for Series ID (sid) vs passing as parameter.
// Create a Form widget.
class GameMaintain extends StatefulWidget {
  final Series series;
  final Game? game;

  const GameMaintain({super.key, required this.series, this.game});

  @override
  State<GameMaintain> createState() => _GameMaintainState();
}

class _GameMaintainState extends State<GameMaintain> {
  final _formGameKey = GlobalKey<FormState>();
  late Game? game;
  late Series series;
//  late int _sid;
  late int _gid;
  late String _uid;
  late Board board;
  late Player player;

  @override
  void initState() {
    super.initState();
    series = widget.series;
    game = widget.game;
//    _sid = series.sid;
    _gid = game?.docId ?? -1;
//    _uid = game?.pid ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    _uid = bruceUser.uid;
    //Game? game = widget.game;
    String currentGameName = "";
    String currentTeamOne = "";
    String currentTeamTwo = "";
    int currentSquareValue = 0;

    int noGames = 0;

    if ( game != null ) {
      currentGameName = game?.name ?? 'Name';
      currentTeamOne = game?.teamOne ?? 'Team One';
      currentTeamTwo = game?.teamTwo ?? 'Team Two';
      currentSquareValue= game?.squareValue ?? 0;
    }

    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((game != null ) ? 'Edit Game' : 'Add Game'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              //autovalidateMode: AutovalidateMode.always,
              onChanged: () {
                //debugPrint("Something Changed ... Game '$game' Email '$email' ");
                Form.of(primaryFocus!.context!).save();
              },
              key: _formGameKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Game Name: "),
                  TextFormField(
                    initialValue: currentGameName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Game Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      currentGameName = value ?? 'Game 000';
                    },
                  ),
                  const Text("Square Value: "),
                  TextFormField(
                    initialValue: currentSquareValue.toString(),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Initials (<3 chars)';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Square Value is: "$value"');
                      if (value == null || value.isEmpty) {
                        currentSquareValue = 0;
                      } else {
                        currentSquareValue = int.parse(value ?? '0');
                      }
                    },
                  ),
                  const Text("Team One: "),
                  TextFormField(
                    initialValue: currentTeamOne,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team One Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      currentTeamOne = value ?? '';
                    },
                  ),
                  const Text("Team Two: "),
                  TextFormField(
                    initialValue: currentTeamTwo,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team Two Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      currentTeamTwo = value ?? '';
                    },
                  ),
                  Text("Series ID: ${series.key}"),
                  Text("Game ID: ${game?.key ?? 'No Set'}"),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            // if (player == null) {
                            //   log('series_maintain: Getting Player ... ');
                              FirestoreDoc? fsDoc = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid);
                              if (fsDoc != null) {
                                player = fsDoc as Player;
                                log('Got Player for Player ${player.fName}');
                              } else {
                                log('Waiting for Player');
                              }
                            // }
                            if (_formGameKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( game == null ) {
                                log('Add Game');
                                // Add new Game
                                Map<String, dynamic> data =
                                { 'sid': series.docId,
                                  'pid': player.pid,
                                  'name': currentGameName,
                                  'teamOne': currentTeamOne,
                                  'teamTwo': currentTeamTwo,
                                  'squareValue': currentSquareValue,
                                };
                                game = Game(data: data);
                                await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocAdd(game!);
                                // game!.docId = game!.docId; // Set GID to docID
                                // await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocUpdate(game!);
                                log("Add Game ${game!.key}");
                                // Add a default board to Database
                                data = { 'docId': game!.docId, }; // Use same key as Game for Board
                                board = Board(data: data );
                                await DatabaseService(FSDocType.board, uid: _uid, sidKey: series.key, gidKey: game!.key )
                                      .fsDocAdd( board );
                                  // await DatabaseService(uid: _uid, sidKey: series.key).incrementSeriesNoGames(1);
                                  series.noGames = series.noGames+1; // Update class to maintain alignment
                              //   }
                              } else {
                                // Update existing game
                                log('Update Game ${game!.key}');
                                Map<String, dynamic> data =
                                { 'name': currentGameName,
                                  'teamOne': currentTeamOne,
                                  'teamTwo': currentTeamTwo,
                                  'squareValue': currentSquareValue,
                                };
                                game!.update(data: data);
                                await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocUpdate(game!);
                              }
                              // Save Updates to Shared Preferences
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (game==null)
                              ? null
                              : () async {
                              bool results = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  // titlePadding: EdgeInsets.fromLTRB(6,2,2,2),
                                  // actionsPadding: EdgeInsets.all(2),
                                  // contentPadding: EdgeInsets.fromLTRB(6,2,6,2),
                                  // shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(2.0)
                                  // ),
                                  title: const Text("Delete Game Warning "),
                                  titleTextStyle: Theme.of(context).textTheme.bodyLarge,
                                  contentTextStyle: Theme.of(context).textTheme.bodyLarge,
                                  content: const Text("Are you sure you want to delete this?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                              if (results) {
                                log('Delete Game ... U:$_uid, S:${series.key}, G:${game!.key}');
                                board = await DatabaseService(FSDocType.board, uid: _uid, sidKey: series.key, gidKey: game!.key).fsDoc(docId: game!.docId) as Board;
                                await DatabaseService(FSDocType.board, uid: _uid, sidKey: series.key, gidKey: game!.key).fsDocDelete(board);
                                await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocDelete(game!);
                                // await DatabaseService(uid: _uid, sid: series.sid).incrementSeriesNoGames(-1);
                                series.noGames  = series.noGames -1;
                                Navigator.of(context).pop();
                              } else {
                                log('Game Delete Action Cancelled');
                              }
                            },
                            child: const Text("Delete")),
                      ),                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print("Return without adding game");
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}