import 'dart:developer';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth.dart';

class SettingsForm extends StatefulWidget {
  // const SettingsForm({super.key});
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();

  // form values
  String? _currentFName;
  String? _currentLName;
  String? _currentInitials;
  String? _currentDisplayName;

  @override
  Widget build(BuildContext context) {

    aaUser bruceUser = Provider.of<aaUser>(context);

    return StreamBuilder<Player>(
      stream: DatabaseService(uid: bruceUser.uid).player,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          Player player = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
//          backgroundColor: Colors.blue[900],
              title: const Text('Profile'),
              centerTitle: true,
              elevation: 0,
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text('Update your Profile',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: player.fName,
                  decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your first name' : null,
                    onChanged: (val) => setState(() => _currentFName = val),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: player.lName,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your last name' : null,
                    onChanged: (val) => setState(() => _currentLName = val),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: player.initials,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your desired initials' : null,
                    onChanged: (val) => setState(() => _currentInitials = val),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    initialValue: AuthService().displayName,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter your desired Display Name' : null,
                    onChanged: (val) => setState(() => _currentDisplayName = val),
                  ),
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
                        if(_formKey.currentState!.validate()){
                          await DatabaseService(uid: bruceUser.uid).updatePlayer(
                            _currentFName ?? snapshot.data!.fName,
                            _currentLName ?? snapshot.data!.lName,
                            _currentInitials ?? snapshot.data!.initials
                          );
                          await AuthService().updateDisplayName(
                            _currentDisplayName ?? AuthService().displayName
                          );
                          Navigator.pop(context);
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