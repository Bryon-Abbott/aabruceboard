import 'dart:developer';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/pages/member/member_tile.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/loading.dart';

class MemberList extends StatefulWidget {
  final Community community;

  const MemberList({super.key, required this.community});

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {

  void callback() {
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {

    void callback() {
      setState(() { });
    }

    BruceUser bruceUser = Provider.of<BruceUser>(context);

    return StreamBuilder<List<Member>>(
      stream: DatabaseService(FSDocType.member, uid: bruceUser.uid, cidKey: widget.community.key).fsDocList as Stream<List<Member>>,
      builder: (context, snapshots) {
        if(snapshots.hasData) {
          List<Member> member = snapshots.data!;
          return Scaffold(
            appBar: AppBar(
      //            backgroundColor: Colors.blue[900],
                title: Text('Manage Members - Count: ${widget.community.noMembers}/${member.length}'),
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
                    onPressed: () async {
                      log('Pick a user to add ..');
                    },
                    icon: const Icon(Icons.add_circle_outline),
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