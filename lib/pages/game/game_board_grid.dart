import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/grid.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;

// ============================================================================
// Board Grid Widget that provide the functions necessary to manage the
// Selection of squares and renumbering of Row/Column numbers
// ============================================================================
class GameBoardGrid extends StatefulWidget {
  const GameBoardGrid({super.key, required this.game, required this.board, required this.series }); // : super(key: key);
  final Game game;
  final Board board;
  final Series series;

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

  double gridSize = 500;

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

    Player communityPlayer = Provider.of<CommunityPlayerProvider>(context).communityPlayer;
    Player activePlayer = Provider.of<ActivePlayerProvider>(context).activePlayer;
    dev.log('Game Owner: ${communityPlayer.docId}:${communityPlayer.fName} Active Player: ${activePlayer.docId}:${activePlayer.fName}',
        name: "${runtimeType.toString()}:build()" );
    // If these Community Player is Equal to the Active Player it is the owner of the game and can update game/grid information,
    gameOwner = communityPlayer.docId == activePlayer.docId;

    textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.yellow);
    // Calculate screen size
    var padding = MediaQuery.of(context).padding;
    screenHeight =  MediaQuery.of(context).size.height - padding.top - padding.bottom;
    screenWidth = MediaQuery.of(context).size.width - padding.left - padding.right;

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
          return SizedBox(
            height: max(min(screenHeight - 308, gridSize - 1), 100),
            width: min(screenWidth - 45, gridSize - 1),
            //width: newScreenWidth-20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: gridSize,
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
            () {
          if (grid.getFreeSquares() == 0) {
            setState(() {
              dev.log("Pressed Number button", name: "${runtimeType.toString()}:NumberButton");
              grid.setScores();
              dev.log("saving Data ... gameNo: ${game.docId} ", name: "${runtimeType.toString()}:NumberButton");
              //board.saveData(games.getGame(games.currentGame).gameNo!);
            });
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
        // onPressed: () {
        //   print("Pressed score button ($scoreIndex: ${gameData.axisScores[scoreIndex]})");
        // },
        // style: ElevatedButton.styleFrom(
        //   backgroundColor:
        //   scores[scoreIndex] == -1 ? Colors.blue : Colors.grey,
        // ),
        //label: Text(""),
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
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          disabledBackgroundColor: getSquareColor(grid, squareIndex),
        ),
        onPressed: (gameOwner && (grid.squarePlayer[squareIndex] == -1)) ? () async {
          dev.log("Pressed game button ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
          // ToDo: need to filter Player-Select to only show players of Communities with Access
            dynamic playerSelected = await Navigator.pushNamed(context, '/player-select');
            if (playerSelected == null) {
              dev.log("No Player Selected", name: "${this.runtimeType.toString()}:GameButton");
            } else {
              Player selectedPlayer = playerSelected as Player;
              dev.log("Player Selected (${selectedPlayer.initials}) as Player)", name: "${this.runtimeType.toString()}:GameButton");
              grid.squarePlayer[squareIndex] = selectedPlayer.docId;
              grid.squareInitials[squareIndex] = selectedPlayer.initials;
              await DatabaseService(FSDocType.grid, sidKey: series.key, gidKey: game.key).fsDocUpdate(grid);
              dev.log("saving Data ... gameNo: ${game.docId} ", name: "${this.runtimeType.toString()}:GameButton");
              setState(() {
                //gameData.saveData(games.getGame(games.currentGame).gameNo!);
              });
              // ToDo: Send Message to user.
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

    int row = index ~/ 10;
    int col = index % 10;

    //int i=0;
    // Scores not set
    if (grid.rowScores[row] == -1 || grid.colScores[col] == -1) {
      return null;
    }

    for (int i = 3; i >= 0; i--) {
      if (board.rowResults[i] == -1 ||
          board.colResults[i] == -1) continue;
      // Get last digit of each score
      lastDigitOne = board.rowResults[i] % 10; // Column Number = Team one
      lastDigitTwo = board.colResults[i] % 10; // Row Number = Team two
      // Check if both are equal
      if ((grid.colScores[col] == lastDigitOne) &&
           grid.rowScores[row] == lastDigitTwo) {
        return Colors.red[(i + 2) * 100];
      }
    }
    return null;
  }
}