import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';
import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/audit.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/access/access_list_members.dart';
import 'package:bruceboard/pages/game/game_summary_page.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:bruceboard/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_board_grid.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/utils/league_list.dart';

const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;
// ===========================================================================
// Desc: Refactored GameBoard from Release 1 to utilize Firebase vs
// SharedPreferences to store the game data.
// ----------
// NOTES:
// Todo: Review resizing functions
// The resizing of the screen is costly from a loading data perspective
// as the data is loaded twice everytime the screen size is changed. This
// will have minimal impact on Mobile instances but is costly for Web and
// desktop apps.
// ----------
// 2023/09/18: Bryon   Created
// 2023/10/24: Bryon   Refactored
// ===========================================================================
class GameBoard extends StatefulWidget {
//  const GameBoard({super.key});
  const GameBoard({super.key, required this.series, required this.game});
  final Series series;
  final Game game;

@override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late Game game;
  late Series series;
//  late String _uid;

  late bool isGameOwner;
  late Map<String, TeamData> leagueTeamData;

  List<Player> winnersPlayer = List<Player>.filled(4, Player(data: {}));
  List<int> winnersCommunity = List<int>.filled(4, -1);

  int cellsPicked=0;
  void callback(int cells)
  {
    cellsPicked = cells;
    dev.log('Callback to reset state: Bought Cells $cellsPicked', name:  '${runtimeType.toString()}:callback()');
    setState(() {});
  }

  late TextStyle textStyle;
  // Todo: Refactor to bring all controllers into a list (or else improve).
  // late TextEditingController controller1, controller2;
  // List<TextEditingController> controllers = [];

  double gridSize = gridSizeSmall;
  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  @override
  void initState() {
    super.initState();
    game = widget.game;
    series = widget.series;
    // controller1 = TextEditingController();
    // controller2 = TextEditingController();

    // for (int i=0; i<4; i++) {
    //   controllers.add(TextEditingController());
    // }

    if (series.type == "NFL") {
      leagueTeamData = nflTeamData;
    } else if (series.type == "NBA") {
      leagueTeamData = nbaTeamData;
    } else if (series.type == "CFL") {
      leagueTeamData = cflTeamData;
    } else if (series.type == "Other") {
      leagueTeamData = <String, TeamData>{};
    }
  }

  @override
  void dispose() {
    // controller1.dispose();
    // controller2.dispose();
    // for (TextEditingController c in controllers ) {
    //   c.dispose;
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    game = widget.game;

//    BruceUser bruceUser = Provider.of<BruceUser>(context);
//    _uid = bruceUser.uid;

    // Calculate screen size
    var padding = MediaQuery.of(context).padding;
    screenHeight = MediaQuery.of(context).size
        .height - padding.top - padding.bottom;
    screenWidth = MediaQuery.of(context).size
        .width - padding.left - padding.right;

    // Dynamically adjust the grid size for Small:Phone / Large:Web,Tablet, etc
    if (screenWidth > 1000) {
      gridSize = gridSizeLarge;
    } else {
      gridSize = gridSizeSmall;
    }
    final Player communityPlayer = Provider.of<CommunityPlayerProvider>(context).communityPlayer;
    final Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    dev.log('Game Owner: ${communityPlayer.docId}:${communityPlayer.fName} Active Player: ${activePlayer.docId}:${activePlayer.fName}',
        name: "${runtimeType.toString()}:build()" );
    // If these Community Player is Equal to the Active Player it is the owner of the game and can update game/grid information,
    isGameOwner = communityPlayer.docId == activePlayer.docId;
    dev.log("Reload Game ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:build()");
    //gameData.loadData(games.getGame(games.currentGame).gameNo!);

    textStyle = Theme.of(context).textTheme.bodySmall!
        .copyWith(color: Colors.yellow);

    return StreamBuilder<FirestoreDoc>(
        stream: DatabaseService(FSDocType.board, uid: communityPlayer.uid, sidKey: series.key, gidKey: game.key).fsDocStream(key: game.key),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Board board = snapshot.data! as Board;
            dev.log("Got Update Board: ${game.docId} ", name: "${runtimeType.toString()}:build()");
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('BruceBoard'),
                  actions: [
                    PopupMenuButton<int>(
                      onSelected: (item) =>
                        onMenuSelected(context, item, board, series, activePlayer, communityPlayer),
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 1,
                          enabled: isGameOwner && board.squaresPicked<100 && !board.scoresLocked,
                          child: const Row(
                            children: [
                              Icon(Icons.filter_list, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Fill remaining"),
                            ]
                          )
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          enabled: isGameOwner && !board.scoresLocked,
                          child: const Row(
                            children: [
                              Icon(Icons.percent_outlined,  color: Colors.white),
                              SizedBox(width: 8),
                              Text("Update Splits"),
                            ]
                          )
                        ),
                        const PopupMenuItem<int>(
                          value: 3,
                          // enabled: isGameOwner,
                          child: Row(
                            children: [
                              Icon(Icons.summarize_outlined, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Game Summary"),
                            ]
                          )
                        ),
                      ]
                    )
                  ],
                  centerTitle: true,
                  elevation: 0,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              //mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      child: const Icon(
                                        Icons.sports_football_outlined,
                                        // color: Colors.yellow,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: SizedBox(
                                    height: 40,
                                    width: min(screenWidth - 48, gridSize - 4),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                        child: Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              (leagueTeamData[game.teamOne] != null)
                                                  ? Image(image: AssetImage(leagueTeamData[game.teamOne]!.teamLogo.path))
                                                  : const Image(image: AssetImage('assets/ball.png'), width: 30,),
                                              const SizedBox(width: 10),
                                              Text(leagueTeamData[game.teamOne]?.teamName ?? game.teamOne), //Text(game.teamTwo),
                                            ]
                                        )
                                      // child: Text(leagueTeamData[game.teamOne]?.teamName ?? game.teamOne),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: SizedBox(
                                    // not less than 100
                                    // height: max(min(screenHeight - 308, gridSize - 4), 100),
                                    // height: max(min(screenHeight - 257, gridSize - 4), 100),
                                    height: max(min(screenHeight - 203, gridSize - 4), 100),
                                    width: 40,
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Expanded(
                                              child: SizedBox(height: 1, width: 1),
                                            ),
                                            Expanded(
                                              child: Text(leagueTeamData[game.teamTwo]?.teamName ?? game.teamTwo,
                                                overflow: TextOverflow.fade,
                                            )),
                                            const SizedBox(width: 10),
                                            (leagueTeamData[game.teamTwo] != null)
                                                ? RotatedBox(
                                                    quarterTurns: 1,
                                                    child: Image(image: AssetImage(leagueTeamData[game.teamTwo]!.teamLogo.path)))
                                                : const Image(image: AssetImage('assets/ball.png'), width: 30,),
                                            const SizedBox(width: 10),
                                          ]
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                      }),
                                  child: Center(
                                    // child: BoardGrid(args: BruceArguments(players, games))
                                      child: GameBoardGrid(game: game,
                                          board: board,
                                          series: series,
                                          callback: callback)
                                  ),
                                )
                              ],
                            ),
//                            const SizedBox(height: 20.0),
                            // buildCredits(board),
                            // buildScore(board, winnersPlayer),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     Text('Owner:${Player.Key(game.pid)} Series:${Series.Key(series.docId)} Game: ${Game.Key(game.docId)}'),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                  ],
                ),
              ),
            );
            //   }
            // );
          } else {
            dev.log("game_test: Error ${snapshot.error}", name: '${runtimeType.toString()}:build()' );
            return const Loading();
          }
        }
    );
  } // end _GameBoard:build()

  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the scores, update quarterly209740
  // results and display winners.
  // --------------------------------------------------------------------------
//  Widget buildScore(double newScreenWidth) {
//   Widget buildScore(Board board, List<Player> winners) {
//
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Container(
//         margin: const EdgeInsets.all(2.0),
//         padding: const EdgeInsets.all(4.0),
//         //height: 100,
//         width: min(screenWidth, gridSize+42),
//         decoration: BoxDecoration(
//           border: Border.all(color: Theme.of(context).colorScheme.outline),
//           borderRadius: BorderRadius.circular(4.0),
// //          color: Colors.amber[900],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children:
//             List<Widget>.generate(1, (index) {
//               return const Row(
//                 //crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text('Score:'),
//                 ],
//               );
//             }) +
//             List.generate(4, (index) {
//               return Wrap(
//                 children: [
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: SizedBox(
//                     width: 21,
//                     child: Text("Q${index + 1}"),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(1.0),
//                     width: 30,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).colorScheme.outline),
//                       color: Theme.of(context).colorScheme.surfaceContainerHighest,  // .surfaceVariant,
//                     ),
//                     child: Text(board.colResults[index].toString(),
//                         textAlign: TextAlign.right),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(1.0),
//                     width: 30,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).colorScheme.outline),
//                       color: Theme.of(context).colorScheme.surfaceContainerHighest,  //.surfaceVariant,
//                     ),
//                     child: Text(board.rowResults[index].toString(),
//                         textAlign: TextAlign.right),
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.all(2.0),
//                   child: SizedBox(
//                     width: 32,
//                     child: Text("Won"),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(1.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(1.0),
//                     width: 100,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).colorScheme.outline),
//                       color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
//                     ),
//                     child: (!board.scoresLocked)
//                         ? const Text("Lock Digits")
//                         : (winners[index].pid == -1)
//                           ? const Text("Enter Scores")
//                           : Text("${winners[index].fName} ${winners[index].lName}"),
//                     // child: Text(getWinners(board.rowResults[index], board.colResults[index], board)
//                     //       .then((value) { return value; } )),
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.all(2.0),
//                   child: SizedBox(
//                     width: 33,
//                     child: Text("Crds"),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(1.0),
//                     width: 35,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).colorScheme.outline),
//                       color: Theme.of(context).colorScheme.surfaceContainerHighest, // .surfaceVariant,
//                     ),
//                     // child: Text('Fix Me'),
//                     child: Text((board.squaresPicked*board.percentSplits[index]*game.squareValue~/100).toString(),
//                          textAlign: TextAlign.right),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(2.0),
//                   child: SizedBox(
//                     height: 25,
//                     width: 45,
//                     child: ElevatedButton(
//                       onPressed: isGameOwner && !board.creditsDistributed ? () async {
//                         dev.log("Getting Scores ... ", name: "${runtimeType.toString()}:buildScore");
//                         final List<String>? score = await openDialogScores(index, board);
//                         if (score == null || score.isEmpty) {
//                           return;
//                         } else {
//                           dev.log("Loading Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:buildScore()");
//                           //gameData.loadData(game.gameNo!);
//                           if (score[0].isNotEmpty) {
//                             board.colResults[index] = int.parse(score[0]);
//                           }
//                           if (score[1].isNotEmpty) {
//                             board.rowResults[index] = int.parse(score[1]);
//                           }
//
//                           dev.log("Saving Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:buildScore()");
//                           DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
//                               .fsDocUpdate(board);
//                           //gameData.saveData(game.gameNo!);
//                           // setState(() {
//                           //   dev.log("setState() ...", name: "${runtimeType.toString()}:buildScore");
//                           // });
//                         }
//                       } : null,
//                       child: const Text('Score'),
//                     ),
//                   ),
//                 ),
//               ]);
//         }),
//         ),
//       ),
//     );
//   } // end _gameBoard:buildScore()
  // --------------------------------------------------------------------------
  // Helper Functions
  // --------------------------------------------------------------------------
  void onMenuSelected(BuildContext context, int item, Board board, Series series, Player activePlayer, Player communityPlayer) async {
    switch (item) {
//       case 0:
//         dev.log("Menu Select 0:Distribute Credits", name: "${runtimeType.toString()}:onMenuSelected");
//         // Verify all winners are set.
//         for (Player p in winnersPlayer) {
//           if (p.pid == -1) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("All scores must be set to distribute credits"))
//             );
//             return;
//           }
//         }
//         // Update Credits and Send messages.
//         for (int i=0; i<4; i++) {
//           Player p = winnersPlayer[i];
//           int c = winnersCommunity[i];
//           // Get exclude Player Number. If no preferences saved for ExcludePlayerNo, default to -1
//           String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ?? "-1";
//           int excludePlayerNo = int.parse(excludePlayerNoString);
//           dev.log("Got Exclude PID ($excludePlayerNo)", name: "${runtimeType.toString()}:onMenuSelected");
//
//           // If Winner is a Player, transfer credits and send message.
//           if (p.docId != excludePlayerNo)  {
//             dev.log("Start Board (${board.docId} Player (${p.docId}) Community ($c)", name: "${runtimeType.toString()}:onMenuSelected");
//             Member member = await DatabaseService(FSDocType.member, cidKey: Community.Key(c))
//                 .fsDoc(docId: p.pid) as Member;
//             dev.log("Got Member (${member.docId})", name: "${runtimeType.toString()}:onMenuSelected");
//             Community community = await DatabaseService(FSDocType.community, cidKey: Community.Key(c))
//                 .fsDoc(docId:winnersCommunity[i]) as Community;
//             dev.log("Got Community (${community.docId})", name: "${runtimeType.toString()}:onMenuSelected");
//             int credits = board.squaresPicked*board.percentSplits[i]*game.squareValue~/100;
//             int prevCredits = member.credits;
//             member.credits += credits; // Add new Credits.
//             DatabaseService(FSDocType.member, cidKey: Community.Key(winnersCommunity[i])).fsDocUpdate(member);
//             // Send Message to user
//             messageSend( 20070, messageType[MessageTypeOption.notification]!,
//               playerFrom: activePlayer, playerTo: winnersPlayer[i],
//               comment: "Thanks for Playing.",
//               description: "You Won the Q${i+1} Score and received $credits credits. Your account was updated from $prevCredits to ${member.credits}) "
//                      "Community: <${community.name}>, Owner: ${activePlayer.fName} ${activePlayer.lName}",
//               data: { 'cid': community.docId, 'credits' : member.credits },
//             );
//             // messageMemberAddCreditsNotification(credits: credits, fromPlayer: activePlayer, toPlayer: winnersPlayer[i],
//             //   description: "You Won the Q${i+1} Score and received $credits credits. Your account was updated from $prevCredits to ${member.credits}) "
//             //       "Community: <${community.name}>, Owner: ${activePlayer.fName} ${activePlayer.lName}",
//             //   comment: "Thanks for Playing.",
//             // );
//           } else {
//             dev.log("Square one by 'No Player' ... ignore", name: "${runtimeType.toString()}:onMenuSelected");
//           }
//         }
//         DatabaseService(FSDocType.board, sidKey:series.key, gidKey:Game.Key(board.docId))
//             .fsDocUpdateField(key:Game.Key(board.docId), field: 'creditsDistributed', bvalue: true );
//
//         dev.log("Winners ${winnersPlayer[0].pid},${winnersPlayer[1].pid},${winnersPlayer[2].pid},${winnersPlayer[3].pid}");
//
// //        widget.gameStorage.writeGameData(BruceArguments(players, games));
//         break;
      case 1:
        dev.log("Menu Select 1:Fill in remainder", name: "${runtimeType.toString()}:onMenuSelected");
        dev.log("Filling scores-Before", name: "${runtimeType.toString()}:onMenuSelected");
        String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ?? "-1";
        int excludePlayerNo = int.parse(excludePlayerNoString);
        dev.log("Got Exclude PID ($excludePlayerNo)", name: "${runtimeType.toString()}:onMenuSelected");

        Grid grid = await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game.key).fsDoc(key: game.key) as Grid;
        if (!context.mounted) return;
        dynamic result = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AccessListMembers(series: series)));
        //dynamic result = await Navigator.pushNamed(context, '/player-select');
        if (result != null) {
          Access selectedAccess = result[0] as Access; // Access Record used for player (contains 'cid' and 'pid'
          Player selectedPlayer = result[1] as Player; // Player player
          Member selectedMember = await DatabaseService(FSDocType.member, cidKey: Community.Key(selectedAccess.cid)).fsDoc(docId: selectedPlayer.docId ) as Member;
          dev.log("Load Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:onMenuSelected");
          int updated = 0;
          int creditsSpent = 0;
          for (int i = 0; i < 100; i++) {
            if (grid.squarePlayer[i] == -1) {
              if ((selectedMember.credits >= game.squareValue) || (selectedPlayer.docId == excludePlayerNo)) {
                grid.squarePlayer[i] = selectedPlayer.docId;
                grid.squareInitials[i] = selectedPlayer.initials;
                grid.squareCommunity[i] = selectedAccess.cid;
                grid.squareStatus[i] = SquareStatus.taken.index; 
                if (selectedPlayer.docId != excludePlayerNo) {
                  selectedMember.credits -= game.squareValue;
                  creditsSpent += game.squareValue;
                }
                updated++;
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Member has run out of credits after $updated squares."))
                );
                break; // Ran out of Credits ... Exit the loop.
              }
            }
          }
          // Update Member Record to reflect credits used.
          DatabaseService(FSDocType.member, cidKey: Community.Key(selectedAccess.cid)).fsDocUpdate(selectedMember);

          Audit audit = Audit(data: {'code': AuditCode.squareFilled.code, 'ownerPid': activePlayer.pid, 'playerPid': selectedPlayer.pid,
            'cid': selectedAccess.cid, 'sid': series.docId, 'gid': game.docId,
            'debit': creditsSpent, 'credit': 0});
          await DatabaseService(FSDocType.audit).fsDocAdd(audit);

          dev.log("Saving Game Data ... Game Board ${game.docId}, Squares $updated", name: "${runtimeType.toString()}:onMenuSelected");
          await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game.key).fsDocUpdate(grid);
          // setState(() { });
        } else {
          dev.log("Return value was null", name: "${runtimeType.toString()}:onMenuSelected");
        }
        // Resync the Board.squaresPicked to the Grid.squaresPicked.
        DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
            .fsDocUpdateField(key: game.key, field: 'squaresPicked', ivalue: grid.getPickedSquares());
        break;
      // case 2:
      //   int qtrPercents = 0;
      //   dev.log("Menu Select 2:Update Splits", name: "${runtimeType.toString()}:onMenuSelected");
      //   final List<String>? percents = await openDialogSplits(board);
      //   if (percents == null || percents.isEmpty) {
      //     return;
      //   } else {
      //     dev.log("Loading Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:onMenuSelected");
      //     for (int i=0; i<4; i++) {
      //       if (percents[i].isNotEmpty) {
      //         board.percentSplits[i] = int.parse(percents[i]);
      //       }
      //       qtrPercents += board.percentSplits[i];
      //       dev.log("Split Data ... '${percents[i]}' ", name: "${runtimeType.toString()}:onMenuSelected");
      //     }
      //     board.percentSplits[4] = 100 - qtrPercents;
      //     dev.log("Split Data ... GameNo: ${game.docId}, Qtr Splits: $qtrPercents,  Total Splits: ${board.percentSplits[4]}", name: "${runtimeType.toString()}:onMenuSelected");
      //
      //     dev.log("Saving Game Data ... GameNo: ${game.docId}", name: "${runtimeType.toString()}:onMenuSelected");
      //     DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
      //         .fsDocUpdate(board);
      //     setState(() {
      //       dev.log("setState() ...", name: "${runtimeType.toString()}:onMenuSelected");
      //     });
      //   }
      //   break;
      case 3:
        dev.log("Summary Options selected ...", name: "${runtimeType.toString()}:onMenuSelected");
        Grid grid = await DatabaseService(FSDocType.grid, uid: communityPlayer.uid,  sidKey: series.key, gidKey: game.key).fsDoc(key: game.key) as Grid;
        if (!context.mounted) return;
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => GameSummaryPage(series: series, game: game, grid: grid, board: board)));
        break;
    }
  }

  // Future<List<String>?> openDialogScores(int qtr, Board board) =>
  //     showDialog<List<String>>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         titlePadding: const EdgeInsets.fromLTRB(6,2,2,2),
  //         actionsPadding: const EdgeInsets.all(2),
  //         contentPadding: const EdgeInsets.fromLTRB(6,2,6,2),
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(2.0)
  //         ),
  //         title: Text("Quarter ${qtr + 1} Score"),
  //         titleTextStyle: Theme.of(context).textTheme.bodyLarge,
  //         contentTextStyle: Theme.of(context).textTheme.bodyLarge,
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               autofocus: true,
  //               decoration: InputDecoration(hintText: game.teamOne ),
  //               style: Theme.of(context).textTheme.bodyMedium,
  //               controller: controller1,
  //               onSubmitted: (_) => submitScores(),
  //             ),
  //             TextField(
  //               autofocus: true,
  //               decoration: InputDecoration(hintText: game.teamTwo),
  //               style: Theme.of(context).textTheme.bodyMedium,
  //               controller: controller2,
  //               onSubmitted: (_) => submitScores(),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: submitScores,
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       ),
  //     ); // end _GameBoard:showDialog()

  // void submitScores() {
  //   Navigator.of(context).pop([controller1.text, controller2.text]);
  //   controller1.clear();
  //   controller2.clear();
  // } // End _GameBoard:submit()

  // Future<List<String>?> openDialogSplits(Board board) => showDialog<List<String>>(
  //   context: context,
  //   builder: (context) => AlertDialog(
  //     titlePadding: const EdgeInsets.fromLTRB(6,2,2,2),
  //     actionsPadding: const EdgeInsets.all(2),
  //     contentPadding: const EdgeInsets.fromLTRB(6,2,6,2),
  //     shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(2.0)
  //     ),
  //     title: const Text("Quarterly Percentage Splits"),
  //     titleTextStyle: Theme.of(context).textTheme.bodyLarge,
  //     contentTextStyle: Theme.of(context).textTheme.bodyLarge,
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: List<Widget>.generate(4, (index) {
  //         controllers[index].value = TextEditingValue(text: board.percentSplits[index].toString());
  //         return Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: SizedBox(
  //             height: 50,
  //             width: 300,
  //             child: TextField(
  //                   //maxLength: 100,
  //                   autofocus: true,
  //                   decoration: InputDecoration(
  //                     label: Text("Qtr ${index+1}"),
  //                     hintText: "Qtr${index + 1}",
  //                   ),
  //                   style: Theme.of(context).textTheme.bodyMedium,
  //                   controller: controllers[index],
  //                   onSubmitted: (_) => submitSplits(),
  //                 ),
  //             ),
  //         );
  //       }),
  //     ),
  //     actions: [
  //       TextButton(
  //         onPressed: submitSplits,
  //         child: const Text('Save'),
  //       ),
  //     ],
  //   ),
  // ); // end _GameBoard:showDialog()

  // void submitSplits() {
  //   Navigator.of(context).pop(List.generate(4, (i) => controllers[i].text));
  //   for (var c in controllers) {
  //     c.clear();
  //   }
  // } // End _GameBoard:submit()

//   Future<List<List>> getWinners(Board board, Player communityPlayer) async {
// //  Future<List<Player>> getWinners(Board board) async {
//     Grid? grid;
//     List<Player> winners = List<Player>.filled(4, Player(data: {}));
//     List<int> community = List<int>.filled(4, -1);
//     // If score is not set yet return TBD
//     //dev.log("Score One : $scoreOne Score two: $scoreTwo", name: "${this.runtimeType.toString()}:getWinner");
//     for (int qtr=0; qtr<=3; qtr++) {
//       dev.log("$qtr:Getting Winner", name: "${runtimeType.toString()}:getWinner");
//       if (board.colResults[qtr] == -1 || board.colResults[qtr] == -1) {
//         // Don't set the winner as Result are not set
//         continue;  // Go to next quarter.
//       } else {
//         // If grid no retrieved, get it.
//         grid ??= await DatabaseService(FSDocType.grid, uid: communityPlayer.uid, sidKey: series.key, gidKey: game.key).fsDoc(key: game.key) as Grid;
//         if (grid.scoresLocked == false) {
//           // Don't set the winner as Scores are not set
//           continue; // Go to next quarter
//         } else {
//           // Get last digit of each score
//           int lastDigitRow = board.rowResults[qtr] % 10; // Row Number = Team two
//           int lastDigitCol = board.colResults[qtr] % 10; // Column Number = Team one
//           dev.log("$qtr:Last digit Row : $lastDigitRow Last digit Col: $lastDigitCol", name: "${runtimeType.toString()}:getWinner");
//           // Get the Row:Col of the winner.
//           int row = grid.rowScores.indexOf(lastDigitRow);
//           int col = grid.colScores.indexOf(lastDigitCol);
//           dev.log("$qtr:Row : $row Col: $col", name: "${runtimeType.toString()}:getWinner");
//           // Find the player number on the board
//           int playerNo = grid.squarePlayer[row * 10 + col];
//           int playerCommunity = grid.squareCommunity[row * 10 + col];
//           Player player = await DatabaseService(FSDocType.player).fsDoc(docId: playerNo) as Player;
//           winners[qtr] = player;
//           community[qtr] = playerCommunity;
//
//           dev.log("$qtr:Player: ${player.docId}:${player.fName} ${player.lName}, Community: $playerCommunity", name: "${runtimeType.toString()}:getWinner");
//         }
//       }
//       dev.log('$qtr:Winner: ${winners[qtr]}', name: "${runtimeType.toString()}:getWinner");
//     }
//     return [winners, community];
//   } // End _GameBoard:getWinners

  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the points and point distribution
  // --------------------------------------------------------------------------
  // Widget buildCredits(double newScreenWidth) {
//   Widget buildCredits(Board board) {
//     List<int> credits = [0,0,0,0,0,0];
//     int totalCredits = 0;
//     int squaresPicked = 0;
//
//     for (int i = 0; i<4; i++) {
// //     credits[i] = board.squaresPicked*board.percentSplits[i]*game.squareValue~/100;
//      credits[i] = squaresPicked*board.percentSplits[i]*game.squareValue~/100;
//      totalCredits += credits[i];
//     }
//
// //    credits[5] = board.squaresPicked * game.squareValue;  // Total Credits collected
//     credits[5] = squaresPicked * game.squareValue;  // Total Credits collected
//     credits[4] = credits[5] - totalCredits;               // calculate the remainder and assign to the community
//
//     return Align(
//       alignment: Alignment.topLeft,
//       child: Container(
//         margin: const EdgeInsets.all(2.0),
//         padding: const EdgeInsets.all(2.0),
//         width: min(screenWidth, gridSize+42),
//         decoration: BoxDecoration(
//           border: Border.all(color: Theme.of(context).colorScheme.outline),
//           borderRadius: BorderRadius.circular(4.0),
//        //   color: Colors.amber[900],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//              const Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text('Credits:'),
//                 ],
//               ),
//             Wrap(
//               children:
//                 List.generate(5, (index) {
//                   dev.log("List.generate Index $index", name: "${runtimeType.toString()}:buildCredits");
//                   return SizedBox(
//                     width: 70,
//                     child: Row(
//                       children: [
//                         Text((index < 4) ? "Q${index+1}:" : (index == 4) ? "Com:" : "?"),
//                         Padding(
//                           padding: const EdgeInsets.all(2.0),
//                           child: Container(
//                             padding: const EdgeInsets.all(1.0),
//                             width: 30,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Theme.of(context).colorScheme.outline),
//                               color: Theme.of(context).colorScheme.surfaceContainerHighest,   // .surfaceVariant,
//                             ),
//                             child: Text((credits[index]).toString(),
//                                 textAlign: TextAlign.right),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 })
//             ),
//           ],
//         ),
//       ),
//     );
//   }
} // End _GameBoard:
