import 'dart:developer';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/database.dart';

// Todo: Look at provider for Series ID (sid) vs passing as parameter.
// Create a Form widget.
class MemberMaintain extends StatefulWidget {
  final Community community;
  final Member? member;

  const MemberMaintain({super.key, required this.community, this.member});

  @override
  State<MemberMaintain> createState() => _MemberMaintainState();
}

class _MemberMaintainState extends State<MemberMaintain> {
  final _formMemberKey = GlobalKey<FormState>();
  late Member? member;
  late Community community;
//  late String _cid;
//   late String _pid;
//   late String _uid;

  @override
  void initState() {
    community = widget.community;
    member = widget.member;
//    _cid = community.key;
//    _uid = member?.uid ?? 'error';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BruceUser bruceUser = Provider.of<BruceUser>(context);
    //_uid = bruceUser.uid;
    int currentCredits = 0;
    int noMembers = 0;

    if ( member != null ) {
      currentCredits = member?.credits ?? 0;
    }

    // Build a Form widget using the _formMemberKey created above.
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
//            backgroundColor: Colors.blue[900],
            title: Text((member != null ) ? 'Edit Member' : 'Add Member'),
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
                //debugPrint("Something Changed ... Member '$member' Email '$email' ");
                Form.of(primaryFocus!.context!).save();
              },
              key: _formMemberKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Member Credits: "),
                  TextFormField(
                    initialValue: currentCredits.toString(),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Member Credits';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      //debugPrint('Member name is: $value');
                      currentCredits = int.parse(value ?? '0');
                    },
                  ),
                  Text("Community  ID: $community.key"),
                  Text("Player ID: ${bruceUser.uid} ?? 'No Set'}"),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formMemberKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if ( member == null ) {
                                log('Add Member');
                                // Add new Member
                                Map<String, dynamic> data =
                                { 'uid': bruceUser.uid,
                                  'credits' : 0,
                                };
                                member = Member(data: data);
                                await DatabaseService(FSDocType.member, uid: bruceUser.uid, cidKey: community.key).fsDocAdd(member!);
                                // Add a default board to Database
                                  // await DatabaseService(uid: _pid, cid: _cid).incrementCommunityNoMembers(1);
                                  widget.community.noMembers++;  // =widget.series.noMembers+1; // Update class to maintain alignment
                              } else {
                                // update existing member
                                //log('Update Member $_gid');
                                Map<String, dynamic> data = {
                                  'credits' : 0,
                                };
                                member!.update(data: data);
                                await DatabaseService(FSDocType.member, uid: bruceUser.uid, cidKey: community.key).fsDocUpdate(member!);                              }
                              // Save Updates to Shared Preferences
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: (member==null)
                              ? null
                              : () async {
                              bool results = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Member Warning ... "),
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
                                log('Delete Member ... C:${community.key}, U:${bruceUser.uid}');
                                await DatabaseService(FSDocType.member, uid: bruceUser.uid, cidKey: community.key).fsDocDelete(member!);
                                widget.community.noMembers  = widget.community.noMembers -1;
                                Navigator.of(context).pop();
                              } else {
                                log('Member Delete Action Cancelled');
                              }
                            },
                            child: const Text("Delete")),
                      ),                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print("Return without adding member");
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