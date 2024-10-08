import 'dart:developer';
import 'package:bruceboard/pages/audit/audit_game_detail_view.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class AuditGameDetailReport extends StatefulWidget {
  final Series series;
  final Game game; 
  const AuditGameDetailReport({super.key,
    required this.series,
    required this.game, 
  });

  @override
  State<AuditGameDetailReport> createState() => _AuditGameDetailReportState();
}

class _AuditGameDetailReportState extends State<AuditGameDetailReport> {
  List<Audit> auditLogs = [];
  late final Series series;
  late final Game game;

  @override void initState() {
    series = widget.series;
    game = widget.game;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Community? community;
//    Series? series;
    log('Getting Records: SID: ${series.docId} GID: ${game.docId}',
        name: "${runtimeType.toString()}:build()");
    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.audit)
          .fsDocQueryListStream(
          queryValues: {
            'sid': series.docId,
            'gid': game.docId
          }
        ),
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            auditLogs = snapshots.data!.map((a) => a as Audit).toList();
            if (auditLogs.isNotEmpty) {
              return FutureBuilder<FirestoreDoc?>(
                future: DatabaseService(FSDocType.community).fsDoc(docId: auditLogs[0].cid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    community = snapshot.data as Community;
                  }
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Audit Report'),
                      centerTitle: true,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        // if user presses back, cancels changes to list (order/deletes)
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    body: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AuditGameDetailView(
                        auditLogs,
                        community: community,
                        series: series,
                        game: game,
                      )
                    ),
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
          } else {
            return Loading();
          }
        }
      ),
    );
  }
}
