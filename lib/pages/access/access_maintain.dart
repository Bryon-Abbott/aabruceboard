import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';

// Create a Form widget.
class AccessMaintain extends StatefulWidget {

  final Access? access;
  const AccessMaintain({super.key, this.access});

  @override
  AccessMaintainState createState() => AccessMaintainState();
}

class AccessMaintainState extends State<AccessMaintain> {
  final _formMembershipKey = GlobalKey<FormState>();
  Access? access;

  @override
  void initState() {
    super.initState();
    access = widget.access;
  }

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    String uid = bruceUser.uid;
    late int cid;
//    Membership membership = Provider.of<Membership>(context);
    String currentStatus = "";

    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((access != null ) ? 'Edit Membership' : 'Add Membership'),
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
              key: _formMembershipKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Community ID: "),
                  TextFormField(
                    readOnly: true,
                    initialValue: 'Select Community',
                  ),
                  const Text("Membership Status: "),
                  TextFormField(
                    initialValue: currentStatus,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Membership Status';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      currentStatus = value ?? 'Pending';
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Number of Members: ???"),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formMembershipKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( access == null ) {
                                // Add new Game
                                Access access = Access(data: {
                                  'cid': cid,
                                  'pid': -1,  // Todo: Fix this?
                                  'uid': uid,
                                  'status': 'Requested',
                                });
                                await DatabaseService(FSDocType.access, uid: uid).fsDocAdd(access);
                                //widget.membership?.noGames++;
                              } else {
                                // update existing game
                                await DatabaseService(FSDocType.access, uid: uid).fsDocUpdate(access!);
                              }
                              // Save Updates to Shared Preferences
                              log("membership_maintain: Added/Updated membership ${access?.cid}");
                              Navigator.of(context).pop(widget.access);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: (access==null)
                            ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Must delete ALL memberships"),
                                )
                              );
                            }
                            : () {
                              log('Delete Membership ...');
                              DatabaseService(FSDocType.membership, uid: uid).fsDocDelete(access!);
                              Navigator.of(context).pop();
                            },
                        child: const Text("Delete")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print("Return without adding membership");
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