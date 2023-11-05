import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';

class PlayerProfile extends StatefulWidget {
  // const PlayerProfile({super.key});
  @override
  _PlayerProfileState createState() => _PlayerProfileState();
}

class _PlayerProfileState extends State<PlayerProfile> {

  final _formKey = GlobalKey<FormState>();

  // Todo: Clean this up ... why all the form fields, etc

  // form values
  String? _currentFName;
  String? _currentLName;
  String? _currentInitials;
  String? _currentDisplayName;

  @override
  Widget build(BuildContext context) {

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<Player>(
      stream: DatabaseService(uid: bruceUser.uid).playerStream,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          Player player = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
//          backgroundColor: Colors.blue[900],
              title: const Text('Player Profile'),
              centerTitle: true,
              elevation: 0,
            ),
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text("First Name"),
                  TextFormField(
                    initialValue: player.fName,
                  decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your first name' : null,
                    onChanged: (val) => setState(() => _currentFName = val),
                  ),
                  SizedBox(height: 10.0),
                  Text("Last Name"),
                  TextFormField(
                    initialValue: player.lName,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your last name' : null,
                    onChanged: (val) => setState(() => _currentLName = val),
                  ),
                  SizedBox(height: 10.0),
                  Text("Initials"),
                  TextFormField(
                    initialValue: player.initials,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your desired initials' : null,
                    onChanged: (val) => setState(() => _currentInitials = val),
                  ),
                  SizedBox(height: 10.0),
                  Text("Display Name"),
                  TextFormField(
                    initialValue: AuthService().displayName,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your desired Display Name' : null,
                    onChanged: (val) => setState(() => _currentDisplayName = val),
                  ),
                  SizedBox(height: 10,),
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
                      child: Text('Update',),
//                        style: TextStyle(color: Colors.white),
//                      ),
                      onPressed: () async {
                        if(_formKey.currentState!.validate()) {
                            // await DatabaseService(uid: bruceUser.uid).updatePlayer(
                            //     _currentFName ?? snapshot.data!.fName,
                            //     _currentLName ?? snapshot.data!.lName,
                            //     _currentInitials ?? snapshot.data!.initials,
                            //     snapshot.data!.pid,
                            // );
                            player.fName = _currentFName ?? snapshot.data!.fName;
                            player.lName = _currentLName ?? snapshot.data!.lName;
                            player.initials = _currentInitials ?? snapshot.data!.initials;
                            player.pid = snapshot.data!.pid;
                            await DatabaseService(uid: bruceUser.uid).updatePlayer(
                              player: player,
                            );
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
          );
        } else {
          return Loading();
        }
      }
    );
  }
}