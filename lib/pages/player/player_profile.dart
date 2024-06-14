import 'dart:developer';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/auth.dart';
// import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';

class PlayerProfile extends StatefulWidget {
  const PlayerProfile({super.key});

  @override
  State<PlayerProfile> createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {

  final _formKey = GlobalKey<FormState>();

  // form values
  String? _currentFName;
  String? _currentLName;
  String? _currentInitials;
  String? _currentDisplayName;
  // Todo: reduce the number of time the database is hit.
  @override
  Widget build(BuildContext context) {

    BruceUser? bruceUser = Provider.of<BruceUser?>(context);
    // log('Bruce User ID ${bruceUser.uid}');
    if (bruceUser != null) {
      return StreamBuilder<FirestoreDoc>(
          stream: DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocStream( key: bruceUser.uid ),
          builder: (context, snapshot) {
            log('player_profile: ${snapshot.data}', name: "${runtimeType.toString()}:build()");
            if(snapshot.hasData) {
              Player player = snapshot.data! as Player;
              return Scaffold(
                appBar: AppBar(
//          backgroundColor: Colors.blue[900],
                  title: const Text('Player Profile'),
                  centerTitle: true,
                  elevation: 0,
                ),
                body: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20.0),
                        const Text("First Name"),
                        TextFormField(
                          initialValue: player.fName,
//                          decoration: textInputDecoration,
                          validator: (val) => val!.isEmpty ? 'Please enter your first name' : null,
                          onChanged: (val) => setState(() => _currentFName = val),
                        ),
                        const SizedBox(height: 10.0),
                        const Text("Last Name"),
                        TextFormField(
                          initialValue: player.lName,
//                          decoration: textInputDecoration,
                          validator: (val) => val!.isEmpty ? 'Please enter your last name' : null,
                          onChanged: (val) => setState(() => _currentLName = val),
                        ),
                        const SizedBox(height: 10.0),
                        const Text("Initials"),
                        TextFormField(
                          initialValue: player.initials,
//                          decoration: textInputDecoration,
                          validator: (val) => val!.isEmpty ? 'Please enter your desired initials' : null,
                          onChanged: (val) => setState(() => _currentInitials = val),
                        ),
                        const SizedBox(height: 10.0),
                        const Text("Display Name"),
                        TextFormField(
                          initialValue: AuthService().displayName,
//                          decoration: textInputDecoration,
                          validator: (val) => val!.isEmpty ? 'Please enter your desired Display Name' : null,
                          onChanged: (val) => setState(() => _currentDisplayName = val),
                        ),
                        const SizedBox(height: 10,),
                        Text("Player Number: ${player.pid}"),
                        Text("Number of Memberships: ${player.noMemberships}"),
                        Text("Number of Communities: ${player.noCommunities}"),
                        Text("Number of Series: ${player.noSeries}"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            // style: ButtonStyle(
                            //   backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[400]!),
                            // ),
                              child: const Text('Update',),
                              //                        style: TextStyle(color: Colors.white),
                              //                      ),
                              onPressed: () async {
                                if(_formKey.currentState!.validate()) {
                                  player.fName = _currentFName ?? player.fName;
                                  player.lName = _currentLName ?? player.lName;
                                  player.initials = _currentInitials ?? player.initials;
                                  player.pid = player.pid;
                                  // log("player_profile: Update Player ${player.fName}");
                                  await DatabaseService(FSDocType.player, uid: bruceUser.uid).fsDocUpdate(player);
                                  await AuthService().updateDisplayName(
                                      _currentDisplayName ?? AuthService().displayName
                                  );
                                  setState(() {
                                    Navigator.pop(context);
                                  }
                                  );
                                }
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              log("No Player found ...", name: "${runtimeType.toString()}:build()");
              return const Loading();
            }
          }
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Player Profile'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("Not Signed On ... ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }
  }
}