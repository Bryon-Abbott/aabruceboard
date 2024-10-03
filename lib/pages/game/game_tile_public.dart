import 'dart:developer';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_board.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GameTilePublic extends StatelessWidget {
  final Game game;
  final Player gameOwner;

  GameTilePublic({super.key, required this.game, required this.gameOwner });

  @override
  Widget build(BuildContext context) {
    String iconSvg = getHarveyBallSvg(0);
    Board? board;
    Series? series;

    final MembershipProvider membershipProvider = Provider.of<MembershipProvider>(context);
    final CommunityPlayerProvider communityPlayerProvider = Provider.of<CommunityPlayerProvider>(context);

    return StreamBuilder<FirestoreDoc>(
      stream: DatabaseService(FSDocType.board, uid: gameOwner.uid, gidKey: Game.Key(game.docId), sidKey: Series.Key(game.sid))
          .fsDocStream(key: Board.Key(game.docId)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          board = snapshot.data as Board;
          iconSvg = getHarveyBallSvg(board!.squaresPicked);
        }
        return FutureBuilder<FirestoreDoc?>(
          future: DatabaseService(FSDocType.series, uid: gameOwner.uid, sidKey: Series.Key(game.sid))
              .fsDoc(key: Series.Key(game.sid)),
          builder: (context, snapshotSeries) {
            if (snapshotSeries.hasData) {
              series = snapshotSeries.data as Series;
            }
            return Card(
              margin: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
              child: ListTile(
                onTap: () async {
                  log("Pool Tapped ... ${game.name} ", name: '${runtimeType.toString()}:build()');
                  List<Membership> memberships = await hasAccess(spid: game.pid, sid: game.sid);
                  if (memberships.isEmpty) {
                    log("No Access Found ... Request Access   ", name: '${runtimeType.toString()}:build()');
                    requestAccess(context, game, gameOwner);
                    // if (context.mounted) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text("Request Access from ${gameOwner.fName} ${gameOwner.lName} through the 'Membership' icon"))
                    //   );
                    // }
                  } else {
                    log("Access Found ... Go to Communities ${Access.KEY(memberships[0].cpid, memberships[0].cid)} ",
                        name: '${runtimeType.toString()}:build()');
                    Player communityPlayer = await DatabaseService(FSDocType.player)
                        .fsDoc(docId: memberships[0].cpid) as Player;
                    communityPlayerProvider.communityPlayer = communityPlayer;
                    Series series = await DatabaseService(FSDocType.series, uid: communityPlayer.uid)
                        .fsDoc(docId: game.sid) as Series;
                    if (memberships.length == 1) {
                      membershipProvider.currentMembership = memberships[0];
                      // Go to Pool ...
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => GameBoard(series: series, game: game)),
                      );
                    } else {
                      Membership? m = await getMembership(context, memberships);
                      if (m != null) {
                        membershipProvider.currentMembership = m;
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GameBoard(series: series, game: game)),
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Access game through 'My Community' tab or 'Memberships' icon"))
                          );
                        }
                      }
                    }
                  }
                },
                leading: SvgPicture.asset(iconSvg,
                  width: 36, height: 36,
                ),
                title: Text('Pool: ${game.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group: ${series?.type ?? "..."}-${series?.name ?? "..."} (${gameOwner.fName} ${gameOwner.lName})'),
                    Text('Date: ${game.gameDate}')
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // Search for all accesses that match any memberships the player has to the given series.
  Future<List<Membership>> hasAccess({required int spid, required int sid}) async {
    List<Membership> myMemberships = [];

    // Get Players Memberships
    List<FirestoreDoc> fsDocs = await DatabaseService(FSDocType.membership).fsDocQueryList(
      queryValues: {'status': "Approved"}
    );
    List<Membership> memberships = fsDocs.map((m) => m as Membership).toList();

    // Get Series Accesses
    List<FirestoreDoc> fsDocs2 = await DatabaseService(FSDocType.access).fsDocGroupList(
      "Access", queryFields: {'pid': spid, 'sid': sid});
    List<Access> accesses = fsDocs2.map((a) => a as Access).toList();

    // Compare Membership and Accesses to see if there is a match
    // For all the access to the series
    for ( Access a in accesses ) {
      log("Looking for Membership with Access ${a.key} ", name: '${runtimeType.toString()}:build()');
      for ( Membership m in memberships ) {
        log("Looking for Membership ${m.key} ", name: '${runtimeType.toString()}:build()');
        // Get All Community Accesses where Players membership matches
        if ((a.cid == m.cid) && (a.pid == m.cpid)) {
          myMemberships.add(m);
        }
      }
    }
    return Future.value(myMemberships);
  }

  // ==========================================================================
  Future<Membership?> getMembership(BuildContext context, List<Membership> memberships) {
    return showDialog<Membership>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
        actionsPadding: const EdgeInsets.all(2),
        contentPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
        title: Text("Select Membership"),
        titleTextStyle: Theme.of(context).textTheme.bodyLarge,
        contentTextStyle: Theme.of(context).textTheme.bodyLarge,
        content: SizedBox(
          height:200,
          width: 300,
          child: ListView.builder(
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Community: ${memberships[index].key}"),
                onTap: () {
                  log("Tapped Membership ${memberships[index].key}");
                  Navigator.of(context).pop(memberships[index]);
                },
              );
            },
          ),
        ),
      ),
    ); //
  }
  // =================================================================================================
  void requestAccess(BuildContext context, Game game, Player gameOwner ) async {
    final BruceUser bruceUser = Provider.of<BruceUser>(context, listen: false);
    final Player activePlayer = Provider.of<ActivePlayerProvider>(context, listen: false).activePlayer;

    if (bruceUser.emailVerified) {
      Series series = await DatabaseService(FSDocType.series, uid: gameOwner.uid).fsDoc(docId: game.sid) as Series;
      Community community = await DatabaseService(FSDocType.community, uid: gameOwner.uid).fsDoc(docId: series.defaultCid) as Community;
      if (!context.mounted) return;
      String? comment = await openDialogMessageComment(context,
        defaultTitle: "Request Community Access",
        defaultComment: "Please add me to your <${community.name}> community."
      );
      log('Comment is $comment', name: '${runtimeType.toString()}:requestAccess()');
      if (comment != null ) {
        Membership membership = Membership(
          data: { 'cid': community.docId, // Community Owner CID
            'cpid': gameOwner.docId,  // Game/Community Onwer PID
            'pid': activePlayer.docId,  // Player PID
            'status': 'Requested',
          }
        );
        DatabaseService(FSDocType.membership).fsDocAdd(membership);
        log("membership_list: Updating MSID: ${membership.docId}", name: '${runtimeType.toString()}:...');
        // Add MemberOwner to Community Player for current Player
        // Process Messages
        messageSend(00010, messageType[MessageTypeOption.request]!,
          playerFrom: activePlayer, playerTo: gameOwner,
          description: '${activePlayer.fName} ${activePlayer.lName} requested to be added to your <${community.name}> community',
          comment: comment,
          data: {
            'msid': membership.docId, // Membership ID of requesting player   // Not Required?
            'cpid': membership.cpid,  // Community Player ID                  // Is the playerTo but include for completenesss
            'cid': membership.cid,    // Community ID of Community Player
            'pid': membership.pid,                                            // Not Required?
          }
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verify Email to join Communities"))
      );
    }
  }
}