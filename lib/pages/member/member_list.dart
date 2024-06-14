import 'dart:developer';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/pages/member/member_tile.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class MemberList extends StatefulWidget {
  final Community community;

  const MemberList({super.key, required this.community});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  Player? player;
  Player? playerSelected;
  late Community community;

  @override
  void initState() {
    super.initState();
    community = widget.community;
  }
  // ToDo: What is happening here with 2 callback functions.
  // void callback() {
  //   setState(() { });
  // }

  @override
  Widget build(BuildContext context) {

    void callback() {
      setState(() { });
    }

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<FirestoreDoc>>(
      stream: DatabaseService(FSDocType.member, uid: bruceUser.uid, cidKey: community.key).fsDocListStream,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Member> member = snapshots.data!.map((s) => s as Member).toList();
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Members - Count: ${community.noMembers}/${member.length}'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () async {
                      player = await DatabaseService(FSDocType.player).fsDoc(key: bruceUser.uid) as Player;
                      if (!context.mounted) return;
                      dynamic results = await Navigator.pushNamed(
                          context, '/player-select');
                      if (results != null) {
                        // setState((){
                        // });
                        playerSelected = results as Player;
                        dynamic existingMember = await DatabaseService(FSDocType.member, cidKey: community.key).fsDoc(
                            key: Member.KEY(playerSelected!.pid));
                        if (existingMember == null ) {
                          // Add Member to Community
                          if (!context.mounted) return;
                          String? comment = await openDialogMessageComment(context, defaultComment: "Inviting you to the Team");
                          if (comment != null) {
                            Member member = Member(data:
                            { 'docId': playerSelected!.pid,   // Set the memberID to the pid of the selected player
                              'credits': 0,
                            });
                            await DatabaseService(FSDocType.member, cidKey: community.key).fsDocAdd(member);
                            // Add Message to Archive
                            String desc = '${player!.fName} ${player!.lName} added you to the <${community.name}> community';
                            // 20001: "Add Member Notification",
                            await messageSend( 20010, messageType[MessageTypeOption.notification]!,
                                playerFrom: player!, playerTo: playerSelected!,
                                data: {'cid': community.docId},
                                comment: comment, description: desc);
                            log('member_list: Player Selected ${player?.fName ?? 'No Player?'}');
                          } else {
                            log("member_list: Canceld out of Comment dialog");
                          }
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Member already exist."))
                          );
                        }
                      } else {
                        log("member_list: No player selected");
                      }
                    },
                  )
                ]),
            body: ListView.builder(
              itemCount: member.length,
              itemBuilder: (context, index) {
                return MemberTile(callback: callback, community: widget.community, member: member[index]);
              },
            ),
          );
        } else {
          return const Loading();
        }
      }
    );
    }
  }