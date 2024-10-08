import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/pages/audit/audit_community_summary_report.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
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
    //String uid = bruceUser.uid;
//    late int cid;
    //Community? community = widget.community;
    String currentCommunityName = "";
    String currentCommunityType = "";
    String currentCharity = "";
    String currentCharityNo = "";
//    int currentCommunityNoMembers = 0;
//    int noGames = 0;

    // Todo: Remove this
    if (community != null) {
      //community = community!;
      log('community_maintain: Got Community ${community!.name}');
    } else {
      log('No Community found ... New community, dont use until created?');
    }

    if ( community != null ) {
      currentCommunityName = community?.name ?? 'xxx';
      currentCommunityType = community?.type ?? 'xxx';
      currentCharity = community?.charity ?? '';
      currentCharityNo = community?.charityNo ?? '';
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
            actions: [
              IconButton(
                icon: const Icon(Icons.view_compact_alt_outlined),
                onPressed: (community != null)
                    ? () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)
                      => AuditGameSummaryReport(community: community!))
                  );
                  log('Community Report-Summary: ${community!.docId}:${community!.name}',
                      name: "${runtimeType.toString()}:build()" );
                } : null,
              ),

              IconButton(
                onPressed: () {
                  log("Pressed reset");
                },
                icon: const Icon(Icons.clear_all),
                tooltip: "Reset number of members ...",
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                        const Text("Charity: "),
                        TextFormField(
                          initialValue: currentCharity,
                          // The validator receives the text that the user has entered.
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter type';
                          //   }
                          //   return null;
                          // },
                          onSaved: (String? value) {
                            //debugPrint('Email is: $value');
                            currentCharity = value ?? '';
                          },
                        ),
                        const Text("Charity Number: "),
                        TextFormField(
                          initialValue: currentCharityNo,
                          // The validator receives the text that the user has entered.
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter type';
                          //   }
                          //   return null;
                          // },
                          onSaved: (String? value) {
                            //debugPrint('Email is: $value');
                            currentCharityNo = value ?? '';
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
                                    Player player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    if ( community == null ) {
                                      // Add new Game
                                      data = {
                                        'cid': -1,
                                        'pid': player.pid,
                                        'name': currentCommunityName,
                                        'type': currentCommunityType,
                                        'charity': currentCharity,
                                        'charityNo': currentCharityNo,
                                        'noMembers': 0,
                                      };
                                      community = Community( data: data );
                                      await DatabaseService(FSDocType.community).fsDocAdd(community!);
                                    } else {
                                      // update existing community
                                      data = {
                                        'name': currentCommunityName,
                                        'type': currentCommunityType,
                                        'charity': currentCharity,
                                        'charityNo': currentCharityNo,
                                      };
                                      community!.update(data: data);
                                      await DatabaseService(FSDocType.community).fsDocUpdate(community!);
                                    }
                                    // Save Updates to Shared Preferences
                                    log("community_maintain: Added/Updated community "
                                        "${community?.noMembers}");
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop(community);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (community==null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Community Not Saved"),
                                      )
                                    );
                                  } else if (community!.noMembers > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Must delete ALL members in community"),
                                      )
                                    );
                                  } else {
                                      log('Delete Community ... ${community!.key}');
                                      DatabaseService(FSDocType.community).fsDocDelete(community!);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text("Delete")
                              ),
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
                ),
              ),
              const AdContainer(),
//              (kIsWeb) ? const SizedBox() : const AaBannerAd(),
            ],
          )
      ),
    );
  }
}