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
  late Community? community;

  @override
  void initState() {
    community = widget.community;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //cid = ModalRoute.of(context)!.settings.arguments as String;
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    String uid = bruceUser.uid;
    late int cid;
    //Community? community = widget.community;
    String currentCommunityName = "";
    String currentCommunityType = "";
    int currentCommunityNoMembers = 0;
    int noGames = 0;

    // Todo: Remove this
    if (community != null) {
      community = community!;
      log('community_maintain: Got Community ${community!.name}');
    } else {
      log('No Community found ... New community, dont use until created?');
    }

    if ( community != null ) {
      uid = community!.uid;
      cid = community!.cid;
      currentCommunityName = community?.name ?? 'xxx';
      currentCommunityType = community?.type ?? 'xxx';
      currentCommunityNoMembers = community?.noMembers ?? 0;
    }
    // Build a Form widget using the _formGameKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((community != null ) ? 'Edit Community' : 'Add Community'),
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
                    initialValue: currentCommunityName,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Community Name';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Game name is: $value');
                      currentCommunityName = value ?? 'Community 000';
                    },
                  ),
                  const Text("Type: "),
                  TextFormField(
                    initialValue: currentCommunityType,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter type';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Email is: $value');
                      currentCommunityType = value ?? 'auto-approve';
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
                            Map<String, dynamic> data;
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formCommunityKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( community == null ) {
                                // Add new Game
                                data = {
                                  'cid': -1,
                                  'uid': uid,
                                  'name': currentCommunityName,
                                  'type': currentCommunityType,
                                  'noMembers': 0,
                                };
                                community = Community( data: data );
                                await DatabaseService(uid: uid).addCommunity(
                                    community: community!,
                                );
                              } else {
                                // update existing community
                                data = {
                                  'name': currentCommunityName,
                                  'type': currentCommunityType,
                                };
                                community!.update(data: data);
                                await DatabaseService(uid: uid).updateCommunity(
                                    community: community!
                                );
                              }
                              // Save Updates to Shared Preferences
                              log("community_maintain: Added/Updated community "
                                  "${community?.noMembers}");
                              Navigator.of(context).pop(community);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (community==null || community!.noMembers > 0)
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Must delete ALL members in community"),
                                )
                              );
                            }
                                : () {
                              if (community!.noMembers == 0) {
                                log('Delete Community ... ${community!.key}');
                                DatabaseService(uid: uid).deleteCommunity(community!.key);
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