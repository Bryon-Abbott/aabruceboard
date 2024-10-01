import 'dart:developer';
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
  final Series series;
  final Game game; 
  const AuditGameSummaryReport({super.key,
    required this.series,
    required this.game, 
  });

  @override
  State<AuditGameSummaryReport> createState() => _AuditGameSummaryReportState();
}

class _AuditGameSummaryReportState extends State<AuditGameSummaryReport> {
  List<Audit> auditLogs = [];

  final codeSummary = <int, List<int>>{999: [0,0,0]};  // Initiate the Total Map entry.
  void summarizeCode(Audit a) {
    // Int Array : Count, Credit, Debit
    final currentArray = codeSummary.putIfAbsent(a.code, () => [0,0,0]);
    codeSummary[a.code] = [currentArray[0]+1,currentArray[1]+a.credit, currentArray[2]+a.debit];
    codeSummary[999]![0] += 1;
    codeSummary[999]![1] += a.credit;
    codeSummary[999]![2] += a.debit;
  }

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

  // Future<Map<int, String>> getPlayerNames(List<int> players) async {
  //   Map<int, String> playerNames = <int, String>{};
  //   for( int p in players ) {
  //     Player player = await DatabaseService(FSDocType.player).fsDoc(docId: ) as Player;
  //     playerNames[p] = "${player.fName} ${player.lName}";
  //   };
  //   return Future.value(playerNames);
  // }

  @override
  Widget build(BuildContext context) {
    Community? community;
    Series? series;
    log('Getting Records: SID: ${widget.series.docId} GID: ${widget.game.docId}',
        name: "${runtimeType.toString()}:build()");
    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.audit)
          .fsDocQueryListStream(
            queryValues: {
              'sid': widget.series.docId,
              'gid': widget.game.docId
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
                  return FutureBuilder<FirestoreDoc?>(
                    future: DatabaseService(FSDocType.series).fsDoc(docId: auditLogs[0].sid),
                    builder: (context, snapshotSeries) {
                      if (snapshotSeries.hasData) {
                        series = snapshotSeries.data as Series;
                      }
                      return FutureBuilder<FirestoreDoc?>(
                        future: DatabaseService(FSDocType.community).fsDoc(docId: auditLogs[0].cid),
                        builder: (context, snapshotCommunity) {
                          if (snapshotCommunity.hasData) {
                            community = snapshotCommunity.data as Community;
                          }
                          return Scaffold(
                            appBar: AppBar(
                                title: const Text('Audit Game Summary Report'),
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
                                    icon: const Icon(Icons.view_headline_outlined),
                                    onPressed: () {
                                      log('Group Report-Detail: ',
                                          name: "${runtimeType.toString()}:build()");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.view_compact_alt_outlined),
                                    onPressed: () {
                                      log('Group Report-Summary: ',
                                          name: "${runtimeType.toString()}:build()");
                                    },
                                  ),
                                ]
                            ),
                            body:
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 633,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 60,
                                        child: AuditGameHeader(
                                          game: widget.game,
                                          community: community,
                                          series: series,
                                        ),
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10,),
                                              const Row(
                                                children: [
                                                  SizedBox(
                                                    width: 268,
                                                    child: Text("Code/Description",
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Cnt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Crt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Dbt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                ],
                                              ),
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: codeKeys.length,
                                                  itemBuilder: (context, index) {
                                                    //var date = DateTime.from (auditLogs[index].timestamp * 1000);
                                                    return Container(
                                                      child: Row(
                                                        children: [
                                                          //Text("Line ... "),
                                                          //Text("${index.toString().padLeft(5, '0')}"),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 268,
                                                                child: Text(
                                                                  "${codeKeys[index]}:${codeKeys[index]==999 ? "    Total" : AuditCode.auditDescription(codeKeys[index]) }",
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 30,
                                                                  child: Text("${codeSummary[codeKeys[index]]![0]}",
                                                                    textAlign: TextAlign.right,)
                                                              ),
                                                              SizedBox(
                                                                  width: 30,
                                                                  child: Text("${codeSummary[codeKeys[index]]![1]}",
                                                                    textAlign: TextAlign.right,)
                                                              ),
                                                              SizedBox(
                                                                  width: 30,
                                                                  child: Text("${codeSummary[codeKeys[index]]![2]}",
                                                                    textAlign: TextAlign.right,)
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                              const SizedBox(height: 10,),
                                              const Row(
                                                children: [
                                                  SizedBox(
                                                    width: 268,
                                                    child: Text("Player ID / Name",
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Cnt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Crt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text("Dbt", textAlign: TextAlign.right,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),),
                                                ],
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: playerKeys.length,
                                                itemBuilder: (context, index) {
                                                  //var date = DateTime.from (auditLogs[index].timestamp * 1000);
                                                  return Container(
                                                    child: Row(
                                                      children: [
                                                        //Text("Line ... "),
                                                        //Text("${index.toString().padLeft(5, '0')}"),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 268,
                                                              child: Text(
                                                                "${playerKeys[index]}:${playerKeys[index]==9999 ? "    Total" : playerNames[playerKeys[index]]}  ",
//                                                                "${playerKeys[index]}:${playerNames[playerKeys[index]]} ",
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 30,
                                                                child: Text("${playerSummary[playerKeys[index]]!["count"]}",
                                                                  textAlign: TextAlign.right,)
                                                            ),
                                                            SizedBox(
                                                                width: 30,
                                                                child: Text("${playerSummary[playerKeys[index]]!["credit"]}",
                                                                  textAlign: TextAlign.right,)
                                                            ),
                                                            SizedBox(
                                                                width: 30,
                                                                child: Text("${playerSummary[playerKeys[index]]!["debit"]}",
                                                                  textAlign: TextAlign.right,)
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 20,
                                          child: AuditGameFooter(game: widget.game)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      );
                    }
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Audit Report'),
                      centerTitle: true,
                      elevation: 0,
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("No Audit Data for Game",
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
