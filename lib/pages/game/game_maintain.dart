import 'dart:developer';

import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
// Todo: Look at provider for Series ID (sid) vs passing as parameter.
// Create a Form widget.
class GameMaintain extends StatefulWidget {
  final Series series;
  final Game? game;

  GameMaintain({super.key, required this.series, this.game});

  @override
  State<GameMaintain> createState() => _GameMaintainState();
}

class _GameMaintainState extends State<GameMaintain> {
  final _formGameKey = GlobalKey<FormState>();
  late Game? game;
  late Series series;
  late String _sid;
  late String _gid;
  late String _pid;

  @override
  void initState() {
    series = widget.series;
    game = widget.game;
    _sid = series.sid;
    _gid = game?.gid ?? 'not set';
    _pid = game?.pid ?? 'not set';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    _pid = bruceUser.uid;
    //Game? game = widget.game;
    String _currentGameName = "";
    String _currentTeamOne = "";
    String _currentTeamTwo = "";
    int _currentSquareValue = 0;

    int noGames = 0;

    if ( game != null ) {
      _currentGameName = game?.name ?? 'Name';
      _currentTeamOne = game?.teamOne ?? 'Team One';
      _currentTeamTwo = game?.teamTwo ?? 'Team Two';
      _currentSquareValue= game?.squareValue ?? 0;
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
                    initialValue: _currentGameName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Game Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      _currentGameName = value ?? 'Game 000';
                    },
                  ),
                  const Text("Square Value: "),
                  TextFormField(
                    initialValue: _currentSquareValue.toString(),
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
                        _currentSquareValue = 0;
                      } else {
                        _currentSquareValue = int.parse(value ?? '0');
                      }
                    },
                  ),
                  const Text("Team One: "),
                  TextFormField(
                    initialValue: _currentTeamOne,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team One Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      _currentTeamOne = value ?? '';
                    },
                  ),
                  const Text("Team Two: "),
                  TextFormField(
                    initialValue: _currentTeamTwo,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team Two Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      _currentTeamTwo = value ?? '';
                    },
                  ),
                  Text("Series ID: ${_sid}"),
                  Text("Game ID: ${_gid ?? 'No Set'}"),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formGameKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( game == null ) {
                                log('Add Game');
                                // Add new Game
                                DocumentReference result = await DatabaseService(pid: _pid, sid: _sid).addGame(
                                  sid: _sid,
                                  pid: _pid,
                                  name: _currentGameName,
                                  teamOne: _currentTeamOne,
                                  teamTwo: _currentTeamTwo,
                                  squareValue: _currentSquareValue,
                                );
                                // Add a default board to Database
                                if (result != null) {
                                  _gid = result.id;
                                }
                                log('Add Board for Game $_gid');
                                await DatabaseService(pid: _pid, sid: _sid, gid: _gid ).addBoard(
                                  gid: _gid,
                                );
                              } else {
                                // update existing game
                                log('Update Game $_gid');
                                await DatabaseService(pid: _pid, sid: _sid).updateGame(
                                  gid: _gid,
                                  sid: _sid,
                                  pid: _pid,
                                  name: _currentGameName,
                                  teamOne: _currentTeamOne,
                                  teamTwo: _currentTeamTwo,
                                  squareValue: _currentSquareValue,
                                );                              }
                              // Save Updates to Shared Preferences
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
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