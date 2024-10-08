import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/audit/audit_game_footer.dart';
import 'package:bruceboard/pages/audit/audit_game_header.dart';
import 'package:flutter/material.dart';

class AuditGameDetailView extends StatelessWidget {
  final List<Audit>auditLogs;
  final Community? community;
  final Series series;
  final Game game;

  const AuditGameDetailView(
    this.auditLogs,
    {
      super.key,
      required this.community,
      required this.series,
      required this.game,
    });

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
        width: 633,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: AuditGameHeader(
                game: game,
                community: community,
                series: series,
              ),
            ),
            Expanded(
              child:
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: auditLogs.length,
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
                                  width: 35,
                                  child: Text("${index.toString().padLeft(3, '0')}: ")
                              ),
                              SizedBox(
                                width: 230,
                                child: Text(
                                  "${auditLogs[index].code} ${AuditCode.auditDescription(auditLogs[index].code)} ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: (auditLogs[index].square ==-1)
                                    ? Text("Sq:")
                                    : Text("Sq: ${auditLogs[index].square.toString().padLeft(2, '0')} "),
                              ),
                              SizedBox(
                                  width: 90,
                                  child: Text("Player: ${auditLogs[index].playerPid} ")
                              ),
                              Text("Time: ${auditLogs[index].timestamp.toDate().toString().substring(0, 23)} "),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
              ),
            ),
            SizedBox(
              height: 20,
              child: AuditGameFooter(game: game)),
          ],
        ),
      );
  }
}
