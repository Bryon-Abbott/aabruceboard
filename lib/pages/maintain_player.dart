import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bruceboard/utils/players.dart';
// https://regex101.com/r/cU5lC2/1
// Create a Form widget.
class MaintainPlayer extends StatefulWidget {
  const MaintainPlayer({super.key});

  @override
  MaintainPlayerState createState() {
    return MaintainPlayerState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MaintainPlayerState extends State<MaintainPlayer> {
  bool playerListChanged = false;
  //late Players allPlayers;
  late Players players;
  late TextEditingController ctlrLName, ctlrFName, ctlrInitials;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.

  final _formPlayerKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    players = Players();
    ctlrFName = TextEditingController();
    ctlrLName = TextEditingController();
    ctlrInitials = TextEditingController();
  }

  @override
  void dispose() {
    ctlrFName.dispose();
    ctlrLName.dispose();
    ctlrInitials.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //allPlayers = ModalRoute.of(context)!.settings.arguments as Players;
    int playerNo = -1;
    String playerFName = "";
    String playerLName = "";
    String playerEmail = "";
    String playerInitials = "";
    String playerPhone = "";

    if (players.currentPlayer >= 0 ) {
      playerNo  = players.getPlayer(players.currentPlayer).playerNo!;
      playerFName = players.getPlayer(players.currentPlayer).fName;
      playerLName = players.getPlayer(players.currentPlayer).lName;
      playerEmail = players.getPlayer(players.currentPlayer).email;
      playerInitials = players.getPlayer(players.currentPlayer).initials;
      playerPhone = players.getPlayer(players.currentPlayer).phone;
    }

    ctlrFName.text = playerFName;
    ctlrLName.text = playerLName;
    ctlrInitials.text = playerInitials;

    // Build a Form widget using the _formPlayerKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((players.currentPlayer >= 0 ) ? 'Edit Player' : 'Add Player'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, playerListChanged);
              },          
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              //autovalidateMode: AutovalidateMode.always,
              onChanged: () {
                //debugPrint("Something Changed ... Player '$player' Email '$email' ");
                Form.of(primaryFocus!.context!).save();
              },
              key: _formPlayerKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Player First Name: "),
                  TextFormField(
                    controller: ctlrFName,
                    textCapitalization: TextCapitalization.words,
                    // initialValue: playerFName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Player First Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      debugPrint('Player name is: $value');
                      if (value!.length == 1) {
                        ctlrInitials.text = ctlrFName.text[0].toUpperCase() + ctlrLName.text[0].toUpperCase();
                      }
                      playerFName = value.toString();
                    },
                  ),
                  const Text("       last Name: "),
                  TextFormField(
                    controller: ctlrLName,
                    textCapitalization: TextCapitalization.words,
                    // initialValue: playerLName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Player Last Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Player name is: $value');
                      if (value!.length == 1) {
                        ctlrInitials.text = ctlrFName.text[0].toUpperCase() + ctlrLName.text[0].toUpperCase();
                      }
                      playerLName = value.toString();
                    },
                  ),
                  const Text("Email: "),
                  TextFormField(
                    initialValue: playerEmail,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      RegExp rex = RegExp(r'^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$');
                      bool matched = false;
                      if (value == null) {
                        return 'Please enter valid email, name@domain.com';
                      } else {
                        matched = rex.hasMatch(value);
                        if (value.isEmpty || !matched) {
                          return 'Please enter valid email, name@domain.com';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      playerEmail = value.toString();
                    },
                  ),
                  const Text("Initials: "),
                  TextFormField(
                    controller: ctlrInitials,
                    textCapitalization: TextCapitalization.characters,
                    // initialValue: playerInitials,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length > 3) {
                          return 'Enter Initials (<3 chars)';
                      } else if  (!players.initialsAreUnique(playerNo, value)) {
                        return 'Initials are not unique';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      playerInitials = value.toString().toUpperCase();
                    },
                  ),
                  const Text("Phone Number: "),
                  TextFormField(
                    initialValue: playerPhone,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      //RegExp rex = RegExp(r'[+][0-9]{1,3}\([0-9]{3}\)[0-9]{3}[-]{1}[0-9]{4}');
                      RegExp rex = RegExp(r'[0-9+()-]{10,17}');
                      bool matched = false;
                      if (value == null) {
                        //return 'Please enter Phone Number in +9(999)999-9999 format';
                        return 'Please enter a 10 to 13 digit Phone Number';
                      } else {
                        matched = rex.hasMatch(value);
                        if (value.isEmpty || !matched) {
                          // return 'Please enter Phone Number in +9(999)999-9999 format';
                          return 'Please enter a 10 to 13 digit Phone Number';
                        }
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('([+0-9)(-])')),
                      LengthLimitingTextInputFormatter(17),
                    ],
                    onSaved: (String? value) {
                      String country="+1";   // Default to North America Country code
                      String phone="9999999999";
                      if (value!.length < 10) return; // Do nothing until at least 10 digits entered
                      String cleanValue = value.replaceAll(RegExp(r'[+()-]+'),'');
                      if (cleanValue.length == 10) {
                        phone = cleanValue;
                      } else {
                        int len = cleanValue.length;
                        country = "+${cleanValue.substring(0, len-10)}";
                        phone = cleanValue.substring(len-10);
                        log("Phone with CC value is '$cleanValue' Country '$country', Phone: '$phone'", name: "${runtimeType.toString()}:build");
                      }
                      // Format +1(999)555-1234
                      log("Phone value is '$cleanValue' Country '$country', Phone: '$phone'", name: "${runtimeType.toString()}:build");
                      playerPhone = "$country(${phone.substring(0,3)})${phone.substring(3,6)}-${phone.substring(6,10)}";
                      //playerPhone = value.toString();
                    },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formPlayerKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if (players.currentPlayer == -1) {
                                // Add new player
                                players.addPlayer(playerFName, playerLName, playerEmail, playerInitials, playerPhone);
                              } else {
                                // update existing player
                                Player p = players.getPlayer(players.currentPlayer);
                                p.fName = playerFName;
                                p.lName = playerLName;
                                p.email = playerEmail;
                                p.initials = playerInitials;
                                p.phone = playerPhone;
                              }
                              // Save Updates to Shared Preferences
                              players.savePlayers();
                              playerListChanged = true;
                              debugPrint("Return and add user ($playerLName/$playerEmail)");
                              Navigator.pop(context, playerListChanged);
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
                              Navigator.pop(context, playerListChanged);
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