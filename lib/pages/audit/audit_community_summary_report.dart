import 'dart:developer';
import 'package:bruceboard/pages/audit/audit_game_summary_view.dart';
import 'package:bruceboard/pages/member/member_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/audit/audit_game_footer.dart';
import 'package:bruceboard/pages/audit/audit_game_header.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class AuditGameSummaryReport extends StatefulWidget {
  final Community community;
  const AuditGameSummaryReport({super.key,
    required this.community,
  });

  @override
  State<AuditGameSummaryReport> createState() => _AuditGameSummaryReportState();
}

class _AuditGameSummaryReportState extends State<AuditGameSummaryReport> {
  List<Audit> auditLogs = [];
  late final Community community;

  @override void initState() {
    community = widget.community;
    super.initState();
  }

  // ----------
  final codeSummary = <int, List<int>>{999: [0,0,0]};  // Initiate the Total Map entry.
  void summarizeCode(Audit a) {
    // Int Array : Count, Credit, Debit
    final currentArray = codeSummary.putIfAbsent(a.code, () => [0,0,0]);
    codeSummary[a.code] = [currentArray[0]+1, currentArray[1]+a.credit, currentArray[2]+a.debit];
    codeSummary[999]![0] += 1;
    codeSummary[999]![1] += a.credit;
    codeSummary[999]![2] += a.debit;
  }

  // ----------
  final playerSummary = <int, Map<String, int>> {9999: {"credit": 0, "debit": 0, "count":0 } };
  final playerNames = <int, String> {};
  void summarizePlayer(Audit a) {
    // Int Array : Count, Credit, Debit
    final playerMap = playerSummary.putIfAbsent(a.playerPid, () => <String, int>{});
    playerSummary[a.playerPid] =
      { "credit": (playerMap["credit"] ?? 0) + a.credit,
        "debit": (playerMap["debit"] ?? 0) + a.debit,
        "count": (playerMap["count"] ?? 0) + 1,
      };
    playerNames[a.playerPid] = " ...";
    playerSummary[9999]!["count"] = playerSummary[9999]!["count"]! + 1;
    playerSummary[9999]!["credit"] = playerSummary[9999]!["credit"]! + a.credit;
    playerSummary[9999]!["debit"] = playerSummary[9999]!["debit"]! + a.debit;
  }

  // ==========================================================================
  Future<List<Player>> getPlayers(List<int> playerNos) async {
    List<Player> players = [];
    for (int pNo = 0; pNo < playerNos.length; pNo++) {
      if (playerNos[pNo] == 9999) continue; // Don't look for player 9999
      Player player = await DatabaseService(FSDocType.player)
          .fsDoc(docId: playerNos[pNo]) as Player;
      players.add(player);
      log("Found Player ${playerNos[pNo]}:${player.fName} ${player.lName} ",
          name: "${runtimeType.toString()}:getNames");
    }
    return players;
  }

  @override
  Widget build(BuildContext context) {
    log('Getting Records: CID: ${community.docId}',
        name: "${runtimeType.toString()}:build()");
    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.audit)
          .fsDocQueryListStream(
            queryValues: {
              'cid': community.docId,
              'ownerPid': community.pid,
            }
          ),
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            auditLogs = snapshots.data!.map((a) => a as Audit).toList();
            auditLogs.forEach(summarizeCode);
            List<int> codeKeys = codeSummary.keys.toList();
            codeKeys.sort();
            auditLogs.forEach(summarizePlayer);
            List<int> playerKeys = playerSummary.keys.toList();
            playerKeys.sort();
            return FutureBuilder<List<Player>>(
              future: getPlayers(playerKeys),
              builder: (context, snapshotNames) {
                if (snapshotNames.hasData) {
                  List<Player> players = snapshotNames.data!;
                  for (Player p in players) {
                    playerNames[p.docId] = "${p.fName} ${p.lName}";
                  }
                }
                if (auditLogs.isNotEmpty) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Community Summary Report'),
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
                      ]
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Community: ${Community.Key(community.docId)} ${community.name}",
                                style: Theme.of(context).textTheme.titleSmall,),
                              Text("Member Credits",
                                style: Theme.of(context).textTheme.titleSmall,),
                              MemberDetailView(community: community),
                              Text("Game Summary",
                                style: Theme.of(context).textTheme.titleSmall,),
                              AuditGameSummaryView(
                                codeKeys: codeKeys, codeSummary: codeSummary,
                                playerKeys: playerKeys, playerSummary: playerSummary, playerNames: playerNames,
                                community: community, series: Series(data: {}), game: Game(data: {})),
                              Text("Footer: ... ",
                                style: Theme.of(context).textTheme.titleSmall,),
                            ],
                          ),
                      ),
                    ),
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Community Summary Report'),
                      centerTitle: true,
                      elevation: 0,
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("No Audit Data for Community",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            );
          } else {
            return Loading();
          }
        }
      ),
    );
  }
}
