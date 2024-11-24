import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/material.dart';

class AuditGameSummaryView extends StatelessWidget {
  final List<int> codeKeys;
  final  Map<int, List<int>> codeSummary;
  final List<int> playerKeys;
  final Map<int, Map<String, int>> playerSummary;
  final Map<int, String>playerNames;
  final Community? community;
  final Series series;
  final Game game;

  const AuditGameSummaryView(
    {
      super.key,
      required this.codeKeys,
      required this.codeSummary,
      required this.playerKeys,
      required this.playerSummary,
      required this.playerNames,
      required this.community,
      required this.series,
      required this.game,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
    //              const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                // SizedBox(
                //  width: 283,
                  child: Text("Code/Description",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text("Trns", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
                SizedBox(
                  width: 35,
                  child: Text("CR", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
                SizedBox(
                  width: 35,
                  child: Text("DR", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: codeKeys.length,
                itemBuilder: (context, index) {
                  //var date = DateTime.from (auditLogs[index].timestamp * 1000);
                  return Row(
                    children: [
                      SizedBox(
                          width: 40,
                          child: Text("${codeKeys[index]}:", textAlign: TextAlign.right,)
                      ),
                      Expanded(
                      // SizedBox(
                      //   width: 283,
                        child: Text(
                          ( codeKeys[index] == 999 ) ? "    Total" : AuditCode.auditDescription(codeKeys[index]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                          width: 35,
                          child: Text("${codeSummary[codeKeys[index]]![0]}",
                            textAlign: TextAlign.right,)
                      ),
                      SizedBox(
                          width: 35,
                          child: Text("${codeSummary[codeKeys[index]]![1]}",
                            textAlign: TextAlign.right,)
                      ),
                      SizedBox(
                          width: 35,
                          child: Text("${codeSummary[codeKeys[index]]![2]}",
                            textAlign: TextAlign.right,)
                      ),
                    ],
                  );
                }),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                // SizedBox(
                //   width: 283,
                  child: Text("Player ID / Name",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text("Trns", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
                SizedBox(
                  width: 35,
                  child: Text("CR", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
                SizedBox(
                  width: 35,
                  child: Text("DR", textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: playerKeys.length,
              itemBuilder: (context, index) {
                //var date = DateTime.from (auditLogs[index].timestamp * 1000);
                return Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text("${playerKeys[index]}:", textAlign: TextAlign.right,),
                    ),
                    Expanded(
                    // SizedBox(
                    //   width: 283,
                      child: Text(
                        "${( playerKeys[index] == 9999 ) ? "    Total" : playerNames[playerKeys[index]]}  ",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                        width: 35,
                        child: Text("${playerSummary[playerKeys[index]]!["count"]}",
                          textAlign: TextAlign.right,)
                    ),
                    SizedBox(
                        width: 35,
                        child: Text("${playerSummary[playerKeys[index]]!["credit"]}",
                          textAlign: TextAlign.right,)
                    ),
                    SizedBox(
                        width: 35,
                        child: Text("${playerSummary[playerKeys[index]]!["debit"]}",
                          textAlign: TextAlign.right,)
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ],
    );
  }
}
