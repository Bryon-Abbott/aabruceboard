import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';
// Create a Form widget.
class CommunityMaintain extends StatefulWidget {

  final Community? community;
  const CommunityMaintain({super.key, this.community});

  @override
  CommunityMaintainState createState() => CommunityMaintainState();
}

class CommunityMaintainState extends State<CommunityMaintain> {
  final _formCommunityKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    String _uid = bruceUser.uid;
    late String _cid;
    Community? community = widget.community;
    String _currentCommunityName = "";
    String _currentCommunityType = "";
    int _currentCommunityNoMembers = 0;
    int noGames = 0;

    // Todo: Remove this
    if (widget.community != null) {
      community = widget.community!;
      log('community_maintain: Got Community ${widget.community!.name}');
    } else {
      log('No Community found ... New community, dont use until created?');
    }

    if ( community != null ) {
//      _uid = community.pid;
      _cid = widget.community!.cid;
      _currentCommunityName = widget.community?.name ?? 'xxx';
      _currentCommunityType = widget.community?.approvalType ?? 'xxx';
      _currentCommunityNoMembers = widget.community?.noMembers ?? 0;
    }
    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((widget.community != null ) ? 'Edit Community' : 'Add Community'),
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
                Form.of(primaryFocus!.context!).save();
              },
              key: _formCommunityKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Community Name: "),
                  TextFormField(
                    initialValue: _currentCommunityName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Community Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      _currentCommunityName = value ?? 'Community 000';
                    },
                  ),
                  const Text("Type: "),
                  TextFormField(
                    initialValue: _currentCommunityType,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter type';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      _currentCommunityType = value ?? 'auto-approve';
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Number of Members: ${community?.noMembers ?? 'N/A'}"),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formCommunityKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( widget.community == null ) {
                                // Add new Game
                                await DatabaseService(uid: _uid).addCommunity(
                                    name: _currentCommunityName,
                                    approvalType: _currentCommunityType,
                                    noMembers: _currentCommunityNoMembers,
                                );
                              } else {
                                // update existing community
                                await DatabaseService(uid: _uid).updateCommunity(
                                  cid: widget.community?.cid ?? 'Error',
                                  name: _currentCommunityName,
                                  approvalType: _currentCommunityType,
                                  noMembers: _currentCommunityNoMembers,
                                );
                              }
                              // Save Updates to Shared Preferences
                              log("community_maintain: Added/Updated community "
                                  "${widget.community?.noMembers}");
                              Navigator.of(context).pop(widget.community);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (community==null || community.noMembers > 0)
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Must delete ALL members in community"),
                                )
                              );
                            }
                                : () {
                              if (community!.noMembers == 0) {
                                log('Delete Community ...');
                                DatabaseService(uid: _uid).deleteCommunity(_cid);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Delete")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print("Return without adding community");
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