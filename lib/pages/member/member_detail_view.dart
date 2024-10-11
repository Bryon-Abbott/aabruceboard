import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';

class MemberDetailView extends StatefulWidget {
  final Community community;

  const MemberDetailView({super.key, required this.community,});

  @override
  State<MemberDetailView> createState() => _MemberDetailViewState();
}

class _MemberDetailViewState extends State<MemberDetailView> {
  List<Member>members=[];
  late Community community;
  int totalCredits=0;

  @override void initState() {
    community = widget.community;
    super.initState();
  }

  // ----------
  final playerNames = <int, String> {};

  int sumIntegers(List<Member> members) {
    return members.fold(0, (int sum, Member member) => sum + member.credits);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FirestoreDoc>>(
      future: DatabaseService(FSDocType.member, cidKey: Community.Key(community.docId))
        .fsDocList,
      builder: (context, snapshots) {
        if (snapshots.hasData) {
          members = snapshots.data!.map((a) => a as Member).toList();
          int totalCredits = sumIntegers(members);
          return SizedBox(
            width: 633,
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 290,
                      child: Text("Player Number / Name: ",
                        style: Theme.of(context).textTheme.titleSmall,),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text("Credits", textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleSmall,),
                    ),
                  ]
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      Player? player;
                      return FutureBuilder<FirestoreDoc?>(
                        future: DatabaseService(FSDocType.player).fsDoc(docId: members[index].docId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            player = snapshot.data as Player;
                          }
                          return Row(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text("${members[index].docId}:", textAlign: TextAlign.right),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: (player == null)
                                      ? Text(
                                          "...",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    : Text(
                                        "${player!.fName} ${player!.lName}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      "${members[index].credits} ",
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      );
                    }
                  ),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 290,
                      child: Text("Total Credits: ", textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleSmall,),
                      ),
                    SizedBox(
                      width: 50,
                      child: Text(totalCredits.toString(), textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleSmall,),
                    )
                  ],
                ),
              ],
            ),
          );
        } else {
          return Loading();
        }
      }
    );
  }
}
