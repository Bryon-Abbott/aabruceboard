import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/utils/games.dart';
// Create a Form widget.
class MaintainGame extends StatefulWidget {
  const MaintainGame({super.key});

  @override
  MaintainGameState createState() {
    return MaintainGameState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MaintainGameState extends State<MaintainGame> {
  bool gameListChanged = false;
//  late Games allGames;
  late Games games;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formGameKey = GlobalKey<FormState>();

  @override
  void initState() {
    games = Games();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    allGames = ModalRoute.of(context)!.settings.arguments as Games;

    String gameName = "";
    String gameOwner = "";
    int gameSquareValue = 0;
    String gameTeamOne = "";
    String gameTeamTwo = "";

    if (games.currentGame >= 0 ) {
      gameName = games.getGame(games.currentGame).name;
      gameOwner = games.getGame(games.currentGame).owner;
      gameSquareValue = games.getGame(games.currentGame).squareValue;
      gameTeamOne = games.getGame(games.currentGame).teamOne;
      gameTeamTwo = games.getGame(games.currentGame).teamTwo;
    }
    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((games.currentGame >= 0 ) ? 'Edit Game' : 'Add Game'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, gameListChanged);
              },          ),
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
                    initialValue: gameName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Game Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      gameName = value ?? 'Game 000';
                    },
                  ),
                  const Text("Owner: "),
                  TextFormField(
                    initialValue: gameOwner,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Owner';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      gameOwner = value ?? 'Owner';
                    },
                  ),
                  const Text("Square Value: "),
                  TextFormField(
                    initialValue: gameSquareValue.toString(),
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
                        gameSquareValue = 0;
                      } else {
                        gameSquareValue = int.parse(value ?? '0');
                      }
                    },
                  ),
                  const Text("Team One: "),
                  TextFormField(
                    initialValue: gameTeamOne,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team One Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      gameTeamOne = value ?? '';
                    },
                  ),
                  const Text("Team Two: "),
                  TextFormField(
                    initialValue: gameTeamTwo,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Team Two Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      gameTeamTwo = value ?? '';
                    },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formGameKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if (games.currentGame == -1) {
                                // Add new Game
                                games.addGame(gameName, gameOwner, gameSquareValue, gameTeamOne, gameTeamTwo);
                              } else {
                                // update existing game
                                Game p = games.getGame(games.currentGame);
                                p.name = gameName;
                                p.owner = gameOwner;
                                p.squareValue = gameSquareValue;
                                p.teamOne = gameTeamOne;
                                p.teamTwo = gameTeamTwo;
                              }
                              // Save Updates to Shared Preferences
                              games.saveGames();
                              gameListChanged = true;
                              debugPrint("Return and add user ($gameName/$gameOwner)");
                              Navigator.pop(context, gameListChanged);
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(content: Text('Processing Data')),
                              // );
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
                                print("Return without adding user");
                              }
                              Navigator.pop(context, gameListChanged);
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