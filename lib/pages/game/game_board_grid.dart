import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/pages/access/access_list_members.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;

// ============================================================================
// Board Grid Widget that provide the functions necessary to manage the
// Selection of squares and renumbering of Row/Column numbers
// ============================================================================
class GameBoardGrid extends StatefulWidget {
  final Game game;
  final Board board;
  final Series series;
  final Function(int cellPicked) callback;

  const GameBoardGrid({super.key, required this.game, required this.board, required this.series, required this.callback}); // : super(key: key);

  @override
  State<GameBoardGrid> createState() => _GameBoardGridState();
}

class _GameBoardGridState extends State<GameBoardGrid> {
  late TextStyle textStyle;
  late Game game;
  late Board board;
  late Series series;

  bool gameOwner = false;
  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  late Player activePlayer;
  late Player communityPlayer;
  late Membership currentMembership;

  double gridSize = gridSizeSmall;

  @override
  void initState() {
    super.initState();
    game = widget.game;
    series = widget.series;
    board = widget.board;
    dev.log("Initialize default GameData data.", name: "${runtimeType.toString()}:initState");
  }

  @override
  Widget build(BuildContext context) {

    communityPlayer = Provider.of<CommunityPlayerProvider>(context).communityPlayer;
    activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    currentMembership = Provider.of<MembershipProvider>(context).currentMembership;

    dev.log('Game Owner: ${communityPlayer.docId}:${communityPlayer.fName} Active Player: ${activePlayer.docId}:${activePlayer.fName}',
        name: "${runtimeType.toString()}:build()" );
    // If these Community Player is Equal to the Active Player it is the owner of the game and can update game/grid information,
    gameOwner = communityPlayer.docId == activePlayer.docId;

    board = widget.board; // add to Build so triggers a rebuild

    textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.yellow);
    // Calculate screen size
    var padding = MediaQuery.of(context).padding;
    screenHeight =  MediaQuery.of(context).size.height - padding.top - padding.bottom;
    screenWidth = MediaQuery.of(context).size.width - padding.left - padding.right;
    dev.log("Screen Size is (H/W) : $screenHeight / $screenWidth");

    if (screenWidth > 1000) {
      gridSize = gridSizeLarge;
    } else {
      gridSize = gridSizeSmall;
    }

    dev.log("Reloading Data ... gameNo: ${game.docId}", name: "${runtimeType.toString()}:build()");
    //gameData.loadData(games.getGame(games.currentGame).gameNo!);

    return StreamBuilder<FirestoreDoc?>(
      stream:  DatabaseService(FSDocType.grid, uid: communityPlayer.uid, sidKey: series.key, gidKey: game.key)
          .fsDocStream(key: game.key),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Grid grid = snapshot.data! as Grid;
          dev.log('Building Grid Owner: ${communityPlayer.fName}, Grid ID: ${grid.docId} Initials[4]: ${grid.squareInitials[4]}',
              name: "${runtimeType.toString()}:build()");
          // widget.callback(grid.getBoughtSquares());
          return SizedBox(
//            height: max(min(screenHeight - 308, gridSize - 1), 100),
//            height: max(min(screenHeight - 275, gridSize - 1), 100),
            height: max(min(screenHeight - 220, gridSize - 1), 100),
            width: min(screenWidth - 45, gridSize - 1),
            //width: newScreenWidth-20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
//              physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
//                physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: SizedBox(
                  height: gridSize+1,
                  // These determine the Size of the buttons (~x/11)
                  width: gridSize,
                  child: GridView.count(
                    // return Row(
                    //   children: GridView.count(
                    primary: false,
                    crossAxisCount: 11,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    children: buildSquares(grid),
                  ),
                ),
              ),
            ),
          );
        } else {
          dev.log("Snapshot Error ${snapshot.error} ... loading", name: "${runtimeType.toString()}:build()");
          return const Loading();
        }
      }
    );
  }

  List<Widget> buildSquares(Grid grid) {
    List<Widget> gridButtons = [];
    gridButtons.add(numberButton(grid));
    for (int col = 0; col < 10; col++) {
      gridButtons.add(scoreButton(grid, col, grid.colScores));
    }
    for (int row = 0; row < 10; row++) {
      gridButtons.add(scoreButton(grid, row, grid.rowScores));
      for (int col = 0; col < 10; col++) {
        gridButtons.add(gameButton(grid, row * 10 + col));
      }
    }
    return gridButtons;
  }

  Widget numberButton(Grid grid) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: (grid.getFreeSquares() != 0 || grid.scoresLocked)
            ? null
            :
        //onPressed: (gameData.getFreeSquares() != 0) ? null :
            () async {
          if (grid.getFreeSquares() == 0) {
            dev.log("Pressed Number button", name: "${runtimeType.toString()}:NumberButton");
            // Set the Scores, Save the Grid with new Score Values and Propagate the ScoresLocked to the Board.
            grid.setScores();
            await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game.key)
                .fsDocUpdate(grid);
            await DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
                .fsDocUpdateField(key: board.key, field: 'scoresLocked', bvalue: true);
            dev.log("saving Data ... gameNo: ${game.docId} ", name: "${runtimeType.toString()}:NumberButton");
            // setState(() {
            //   //board.saveData(games.getGame(games.currentGame).gameNo!);
            // });
          } else {
            dev.log("Can't set numbers until board is full", name: "${runtimeType.toString()}:NumberButton");
          }
        },
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        child: (grid.getFreeSquares() != 0 )
            ? Text(grid.getFreeSquares().toString())
            : grid.scoresLocked
              ? const Icon(Icons.lock_outline, color: Colors.red)
              : const Icon(Icons.lock_open_rounded, color: Colors.green),
      ),
    );
  }

  Widget scoreButton(Grid grid, int scoreIndex, List<int> scores) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: (scores[scoreIndex]) == -1 ? null : () {},
        child: (scores[scoreIndex] == -1)
            ? const Text("?")
            : Text( scores[scoreIndex].toString() ),
      ),
    );
  }

  Widget gameButton(Grid grid, int squareIndex) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
//          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textStyle: Theme.of(context).textTheme.bodyMedium,
          disabledBackgroundColor: getSquareColor(grid, squareIndex),
        ),
        onPressed: (grid.squareStatus[squareIndex] == SquareStatus.free.index)
            ? () {
              dev.log("Pressed game button ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
              if (gameOwner) {
                dev.log("Owner Assign Square ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
                assignSquare(context, game, grid, squareIndex);
              } else {
                dev.log("Player Request Square ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
                requestSquare(context, game, grid, squareIndex);
              }
            }
            : null,
        child: Text(grid.squareInitials[squareIndex]),
      ),
    );
  }

  Color? getSquareColor(Grid grid, int index) {
    int lastDigitOne = -1; // Column Number = Team one
    int lastDigitTwo = -1; // Row Number = Team two
    Color? squareColor;
    int row = index ~/ 10;
    int col = index % 10;
    // Scores not set ... only color Requested
    if (grid.rowScores[row] == -1 || grid.colScores[col] == -1) {
      //dev.log("Square ($index) is ${SquareStatus.values[grid.squareStatus[index]].toString()}", name: "${runtimeType.toString()}:getSquareColor");
      if (grid.squareStatus[index] == SquareStatus.requested.index) {
        dev.log("++Square ($index) is ${SquareStatus.values[grid.squareStatus[index]].toString()}", name: "${runtimeType.toString()}:getSquareColor");
        squareColor = Colors.amber[200];
      }
    } else {  // Scores are set ... see if we have any winners.
      for (int i = 3; i >= 0; i--) {
        if (board.rowResults[i] == -1 ||
            board.colResults[i] == -1) continue;
        // Get last digit of each score
        lastDigitOne = board.colResults[i] % 10; // Column Number = Team one
        lastDigitTwo = board.rowResults[i] % 10; // Row Number = Team two
        // Check if both are equal
        if ((grid.colScores[col] == lastDigitOne) &&
            grid.rowScores[row] == lastDigitTwo) {
          squareColor = Colors.red[(i + 2) * 100];
        }
      }
    }
    return squareColor;
  }

  void assignSquare(BuildContext context, Game game, Grid grid, int squareIndex) async {
    dev.log("Assign Square ($squareIndex)", name: "${runtimeType.toString()}:ownerAssignSquare()");
    //dynamic playerSelected = await Navigator.pushNamed(context, '/player-select');
    if (!context.mounted) return;
    dynamic result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AccessListMembers(series: series)),
    );

    if (result == null) {
      dev.log("No Player Selected", name: "${runtimeType.toString()}:GameButton");
    } else {
      // Get Comment
      if (!context.mounted) return;
      String? comment = await openDialogMessageComment(context, defaultComment: "Good Luck with Square $squareIndex");
      if (comment != null) {
        Access selectedAccess = result[0] as Access; // Access Record used for player (contains 'cid' and 'pid'
        Player selectedPlayer = result[1] as Player; // Player player
        dev.log("Player Selected (${selectedPlayer.initials}) as Player)", name: "${runtimeType.toString()}:GameButton");
        grid.squarePlayer[squareIndex] = selectedPlayer.docId;
        grid.squareCommunity[squareIndex] = selectedAccess.cid;
        grid.squareInitials[squareIndex] = selectedPlayer.initials;
        grid.squareStatus[squareIndex] = SquareStatus.taken.index;
        // Get the member record for the player.
        Member member = await DatabaseService(FSDocType.member, cidKey: Community.Key(selectedAccess.cid)).fsDoc(docId: selectedPlayer.pid ) as Member;
        member.credits -= game.squareValue;
        // No need to await here as updates will come via Firestore Streams.
        DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game.key).fsDocUpdate(grid);
        DatabaseService(FSDocType.member, cidKey: Community.Key(selectedAccess.cid)).fsDocUpdate(member);
        DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
            .fsDocUpdateField(key: game.key, field: 'squaresPicked', ivalue: grid.getPickedSquares());
        dev.log("saving Data ... gameNo: ${game.docId} ", name: "${runtimeType.toString()}:GameButton");
        // Send message to user
        await messageSend(20040, messageType[MessageTypeOption.notification]!,
          playerFrom: activePlayer, playerTo: selectedPlayer,
          comment: comment,
          description: "Square $squareIndex for Game <${game.name}> in Series <${series.name}> has been assigned to you for ${game.squareValue} credit(s)."
            " Your Remaining credits in community <${selectedAccess.key}> are ${member.credits}.",
          data: { 'cid': selectedAccess.docId, 'sid': game.sid, 'gid': game.docId, 'squareRequested': squareIndex },
        );
      }
    }
  }

  // Request Square from Series Owner.
  void requestSquare(BuildContext context, Game game, Grid grid, int squareIndex) async {
    dev.log("Request Square ($squareIndex) for Community ID ${currentMembership.cid}", name: "${runtimeType.toString()}:requestSquare()");

    // Get Active Players Member Record from Community to Check Credits.
    FirestoreDoc? fsDoc = await DatabaseService(FSDocType.member, uid: communityPlayer.uid, cidKey: Community.Key(currentMembership.cid))
        .fsDoc(docId: activePlayer.docId);
    if (fsDoc != null) {
      Member member = fsDoc as Member;
      if (member.credits >= game.squareValue) {  // Has Credits
        // Get Comment
        if (!context.mounted) return;
        String? comment = await openDialogMessageComment(context, defaultComment: "Please assign me to Square $squareIndex",
          defaultTitle: "Square Request (Credits: ${member.credits})",
        );
        if (comment != null) {
          // Send message to user
          await messageSend(00040, messageType[MessageTypeOption.request]!,
            playerFrom: activePlayer, playerTo: communityPlayer,
            comment: comment,
            description: "${activePlayer.fName} ${activePlayer.lName} requested Square $squareIndex for Game <${game.name}> in Series <${series.name}>",
            data: { 'cid': currentMembership.cid, 'sid': game.sid, 'gid': game.docId, 'squareRequested': squareIndex },
          );
        } else {
          dev.log("Request Square Cancelled for ($squareIndex)", name: "${runtimeType.toString()}:requestSquare()");
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You do not have enough Credits in your Community Membership (${member.credits}), Square Value ${game.squareValue}"),
            )
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot find Member Record, Ensure Membership request has been accepted"),
          )
      );
      dev.log("No Member ... likey not accepted yet", name: "${runtimeType.toString()}:requestSquare()");
    }

  }
}