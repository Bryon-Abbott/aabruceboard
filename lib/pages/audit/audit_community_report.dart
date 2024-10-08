import 'dart:developer';
import 'package:bruceboard/pages/audit/audit_community_footer.dart';
import 'package:bruceboard/pages/audit/audit_community_header.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

class AuditGameReport extends StatefulWidget {
  final Community community;
  const AuditGameReport({super.key,
    required this.community,
  });

  @override
  State<AuditGameReport> createState() => _AuditGameReportState();
}

class _AuditGameReportState extends State<AuditGameReport> {
  List<Audit> auditLogs = [];

  @override
  Widget build(BuildContext context) {
    Community? community;
    Series? series;
    log('Getting Records: CID: ${widget.community.docId}',
        name: "${runtimeType.toString()}:build()");
    return SafeArea(
      child: StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.audit)
          .fsDocQueryListStream(
          queryValues: {
            'cid': widget.community.docId,
          }
        ),
        builder: (context, snapshots) {
          if(snapshots.hasData) {
            auditLogs = snapshots.data!.map((a) => a as Audit).toList();
            if (auditLogs.isNotEmpty) {
              return FutureBuilder<FirestoreDoc?>(
                future: DatabaseService(FSDocType.series).fsDoc(docId: auditLogs[0].sid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    series = snapshot.data as Series;
                  }
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
                          body:
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 633,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: AuditCommunityHeader(
                                      community: community,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
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
                                      child: AuditCommunityFooter(community: widget.community)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  );
                }
              );
            } else {
              // yyy
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
