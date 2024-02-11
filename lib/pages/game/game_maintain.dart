import 'dart:developer';
import 'package:bruceboard/menus/popupmenubutton_status.dart';
import 'package:bruceboard/menus/popupmenubutton_teamdata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_any_logo/gen/assets.gen.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/utils/league_list.dart';
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
  late int _gid;
  late String _uid;
  late Board board;
  late Grid grid;
  late Player activePlayer;
  late Map<String, TeamData> leagueTeamData;
  late TextEditingController gameNameController;

  String currentGameName = "";
  String currentTeamOne = "";
  String currentTeamTwo = "";
  int currentSquareValue = 0;
  int currentStatus = 0;

  @override
  void initState() {
    super.initState();
    series = widget.series;
    game = widget.game;
    _gid = game?.docId ?? -1;

//    if ( game != null ) {
      currentGameName = game?.name ?? "";
      currentTeamOne = game?.teamOne ?? "Select-Away-Team";
      currentTeamTwo = game?.teamTwo ?? "Select-Home-Team";
      currentSquareValue = game?.squareValue ?? 0;
      currentStatus = game?.status ?? 0;
//    }

    // Set League Data
    if (series.type == "NFL") {
      leagueTeamData = nflTeamData;
    } else if (series.type == "NBA") {
      leagueTeamData = nbaTeamData;
    } else if (series.type == "CFL") {
      leagueTeamData = cflTeamData;
    } else if (series.type == "Other") {
      leagueTeamData = Map<String, TeamData>();
    }

    gameNameController = TextEditingController();
    gameNameController.text = "${leagueTeamData[currentTeamOne]?.teamName ?? currentTeamOne} "
        "vs ${leagueTeamData[currentTeamTwo]?.teamName ?? currentTeamTwo}";
  }

  @override
  void dispose() {
    gameNameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    _uid = bruceUser.uid;

    activePlayer =  Provider.of<ActivePlayerProvider>(context).activePlayer;

    int noGames = 0;

    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
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
                  TextField(
                    enabled: false,
                    controller: gameNameController,
                  ),
                  const Text("Square Value: "),
                  TextFormField(
                    initialValue: currentSquareValue.toString(),
                    // The validator receives the text that the user has entered.
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Integer Value';
                      } else if (currentTeamOne=="" || currentTeamTwo == "") {
                        return 'Select Teams';
                      } else if (currentTeamOne == currentTeamTwo) {
                        return 'Teams can be the same' ;
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
                  const Text("Away Team:"),
                  (series.type == "Other")
                    ? TextFormField(
                        initialValue: currentTeamOne,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Away Team Name';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          //debugPrint('Email is: $value');
                          currentTeamOne = value ?? '';
                          gameNameController.text = "${currentTeamOne} vs ${currentTeamTwo}";
                        },
                      )
                  : PopupMenuButtonTeamData(
                      initialValue: leagueTeamData[currentTeamOne] ?? TeamData("None", "None", "None", const AssetGenImage('assets/question-mark.png')),
                      leagueTeamData: leagueTeamData,
                      onSelected: (TeamData selectedValue) {
                        setState(() {
                          currentTeamOne = selectedValue.teamKey;
                          gameNameController.text = "${leagueTeamData[currentTeamOne]?.teamName ?? 'Select-Away-Team'} "
                                      "vs ${leagueTeamData[currentTeamTwo]?.teamName ?? 'Select-Home-Team'}";
                          currentGameName = gameNameController.text;
                        });
                      },
                  ),
                  const Text("Home Team:"),
                  (series.type == "Other")
                    ?  TextFormField(
                        initialValue: currentTeamTwo,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Home Team Name';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          //debugPrint('Email is: $value');
                          currentTeamTwo = value ?? '';
                          gameNameController.text = "${currentTeamOne} vs ${currentTeamTwo}";
                        },
                      )
                    : PopupMenuButtonTeamData(
                        initialValue: leagueTeamData[currentTeamTwo] ?? TeamData("None", "None", "None", const AssetGenImage('assets/question-mark.png')),
                        leagueTeamData: leagueTeamData,
                        onSelected: (TeamData selectedValue) {
                          setState(() {
                            currentTeamTwo = selectedValue.teamKey;
                            gameNameController.text = "${leagueTeamData[currentTeamOne]?.teamName ?? 'Select-Away-Team'} "
                                "vs ${leagueTeamData[currentTeamTwo]?.teamName ?? 'Select-Home-Team'}";
                            currentGameName = gameNameController.text;
                          });
                        },
                      ),
                  PopupMenuButtonStatus(
                    initialValue: StatusValues.values[currentStatus],
                    // initialValue: StatusValues.Prepare,
                    onSelected: (StatusValues selectValue) {
                      log("Got Selected Value ${selectValue.index} ${selectValue.name}",name: '${runtimeType.toString()}:build()' );
                      setState(() {
                        currentStatus = selectValue.index;
                      });
                    },
                  ),

                  Text("Series ID: ${series.key} " "Game ID: ${game?.key ?? 'Not Set '} " "Game ID: ${activePlayer.docId}"),
                  // Text("Game ID: ${game?.key ?? 'No Set'}"),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            if (_formGameKey.currentState!.validate()) {
                              if ( game == null ) {
                                log('Add Game', name: '${runtimeType.toString()}:builid()');
                                // Add new Game
                                Map<String, dynamic> data =
                                { 'sid': series.docId,
                                  'pid': activePlayer.pid,
                                  'name': currentGameName,
                                  'teamOne': currentTeamOne,
                                  'teamTwo': currentTeamTwo,
                                  'squareValue': currentSquareValue,
                                  'status': currentStatus,
                                };
                                game = Game(data: data);
                                await DatabaseService(FSDocType.game, sidKey: series.key).fsDocAdd(game!);
                                // game!.docId = game!.docId; // Set GID to docID
                                // await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocUpdate(game!);
                                log("Add Game ${game!.key}", name: '${runtimeType.toString()}:builid()');
                                // Add a default board to Database
                                // data = { 'docId': game!.docId, }; // Use same key as Game for Board
                                board = Board(data: { 'docId': game!.docId, } );
                                await DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game!.key )
                                      .fsDocAdd( board );
                                  // await DatabaseService(uid: _uid, sidKey: series.key).incrementSeriesNoGames(1);
                                grid = Grid(data: { 'docId': game!.docId, } );
                                await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game!.key )
                                    .fsDocAdd( grid );
                                // await DatabaseService(uid: _uid, sidKey: series.key).incrementSeriesNoGames(1);
                                  series.noGames = series.noGames+1; // Update class to maintain alignment
                              //   }
                              } else {
                                // Update existing game
                                log('Update Game ${game!.key}', name: '${runtimeType.toString()}:builid()');
                                Map<String, dynamic> data =
                                { 'pid': activePlayer.pid,
                                  'name': currentGameName,
                                  'teamOne': currentTeamOne,
                                  'teamTwo': currentTeamTwo,
                                  'squareValue': currentSquareValue,
                                  'status': currentStatus,
                                };
                                game!.update(data: data);
                                await DatabaseService(FSDocType.game, uid: _uid, sidKey: series.key).fsDocUpdate(game!);
                              }
                              // Save Updates to Shared Preferences
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            child: const Text("Delete"),
                            onPressed: (game == null)
                              ? null
                              : () async {
                              bool results = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
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
                                log('Delete Game ... U:$_uid, S:${series.key}, G:${game!.key}', name: '${runtimeType.toString()}:build()');
                                // ToDo: Should be able to just use Board(data: {docID: game!.docId})
                                board = await DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game!.key).fsDoc(docId: game!.docId) as Board;
                                await DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game!.key).fsDocDelete(board);
                                await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game!.key).fsDocDelete(Grid(data: { 'docID': game!.docId } ));
                                await DatabaseService(FSDocType.game, sidKey: series.key).fsDocDelete(game!);
                                // await DatabaseService(uid: _uid, sid: series.sid).incrementSeriesNoGames(-1);
                                series.noGames  = series.noGames -1;
                                Navigator.of(context).pop();
                              } else {
                                log('Game Delete Action Cancelled', name: '${runtimeType.toString()}:build()');
                              }
                            },
                        ),
                      ),
                      Padding(
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