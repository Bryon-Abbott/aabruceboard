import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/game.dart';

const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;

// ============================================================================
// Board Grid Widget that provide the functions necessary to manage the
// Selection of squares and renumbering of Row/Column numbers
// ============================================================================
class GameBoardGrid extends StatefulWidget {
  const GameBoardGrid({super.key, required this.game, required this.board}); // : super(key: key);
  final Game game;
  final Board board;

  @override
  State<GameBoardGrid> createState() => _GameBoardGridState();
}

class _GameBoardGridState extends State<GameBoardGrid> {
  // double squareBoxSize = 30;

  late TextStyle textStyle;
  late Game game;
  late Board board;

  // late Games games;
  // late GameData gameData;
  // late Players players;

  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  double gridSize = 500;

  @override
  void initState() {
    super.initState();
    game = widget.game;
    // players = widget.args.players;
    //game = widget.game;
    //players = Players();
    //game = games.getGame(games.currentGame);
    dev.log("Initialize default GameData data.", name: "${runtimeType.toString()}:initState");
    board = widget.board;
  }

  @override
  Widget build(BuildContext context) {
    textStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.yellow);
    // Calculate screen size
    var padding = MediaQuery.of(context).padding;
    screenHeight =  MediaQuery.of(context).size.height - padding.top - padding.bottom;
    screenWidth = MediaQuery.of(context).size.width - padding.left - padding.right;

    if (screenWidth > 1000) {
      gridSize = gridSizeLarge;
    } else {
      gridSize = gridSizeSmall;
    }

    dev.log("Reloading Data ... gameNo: ${game.docId}", name: "${runtimeType.toString()}:build");
    //gameData.loadData(games.getGame(games.currentGame).gameNo!);

    return SizedBox(
      height: max(min(screenHeight - 308, gridSize-1), 100),
      width: min(screenWidth - 45, gridSize-1),
      //width: newScreenWidth-20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            height: gridSize,  // These determine the Size of the buttons (~x/11)
            width: gridSize,
            child: GridView.count(
              // return Row(
              //   children: GridView.count(
              primary: false,
              crossAxisCount: 11,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              children: buildSquares(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSquares() {
    List<Widget> grid = [];
    grid.add(numberButton());
    for (int col = 0; col < 10; col++) {
      grid.add(scoreButton(col, board.colScores));
    }
    for (int row = 0; row < 10; row++) {
      grid.add(scoreButton(row, board.rowScores));
      for (int col = 0; col < 10; col++) {
        grid.add(gameButton(row * 10 + col));
      }
    }
    return grid;
  }

  Widget numberButton() {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: (board.getFreeSquares() != 0 || board.scoresLocked)
            ? null
            :
        //onPressed: (gameData.getFreeSquares() != 0) ? null :
            () {
          if (board.getFreeSquares() == 0) {
            setState(() {
              dev.log("Pressed Number button", name: "${runtimeType.toString()}:NumberButton");
              board.setScores();
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
//        style: ElevatedButton.styleFrom(
//          backgroundColor: Colors.green,
//          disabledBackgroundColor: Colors.grey,
//        ),
        //label: Text(""),
        child: (board.getFreeSquares() != 0 )
            ? Text(board.getFreeSquares().toString())
            : board.scoresLocked
            ? const Icon(Icons.lock_outline, color: Colors.red)
            : const Icon(Icons.lock_open_rounded, color: Colors.green),
      ),
    );
  }

  Widget scoreButton(int scoreIndex, List<int> scores) {
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
            : Text(
          scores[scoreIndex].toString(),
        ),
      ),
    );
  }

  Widget gameButton(int squareIndex) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          disabledBackgroundColor: getSquareColor(squareIndex),
        ),
//            : Text(players.searchPlayer(board.boardData[squareIndex])?.initials
//            ?? "??",
//        ),
        onPressed: (board.boardData[squareIndex] == -1) ? () async {
          dev.log("Pressed game button ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
          //   dynamic playerSelected = await Navigator.pushNamed(
          //       context, '/manageplayers',
          //       arguments: BruceArguments(players, games));
          //   if (playerSelected == null) {
          //     dev.log("No Player Selected", name: "${this.runtimeType.toString()}:GameButton");
          //   } else {
          //     setState(() {
          //       Player p = playerSelected as Player;
          //       dev.log("Player Selected (${p.initials}) as Player)", name: "${this.runtimeType.toString()}:GameButton");
          //       board.boardData[squareIndex] = p.playerNo!;
          //       // Save Updates
          //       // String x = this.context.widget.runtimeType;
          //       // String t = this.runtimeType.toString();
          //       dev.log("saving Data ... gameNo: ${game.gid} ", name: "${this.runtimeType.toString()}:GameButton");
          //       //gameData.saveData(games.getGame(games.currentGame).gameNo!);
          //     });
          //   }
        }
            : null,
        child: (board.boardData[squareIndex] == -1)
            ? const Text("FS")
            : const Text("XX"),
      ),
    );
  }

  Color? getSquareColor(int index) {
    int lastDigitOne = -1; // Column Number = Team one
    int lastDigitTwo = -1; // Row Number = Team two

    int row = index ~/ 10;
    int col = index % 10;

    //int i=0;
    // Scores not set
    if (board.rowScores[row] == -1 || board.colScores[col] == -1) {
      return null;
    }

    for (int i = 3; i >= 0; i--) {
      if (board.rowResults[i] == -1 ||
          board.colResults[i] == -1) continue;
      // Get last digit of each score
      lastDigitOne = board.rowResults[i] % 10; // Column Number = Team one
      lastDigitTwo = board.colResults[i] % 10; // Row Number = Team two
      // Check if both are equal
      if ((board.colScores[col] == lastDigitOne) &&
          board.rowScores[row] == lastDigitTwo) {
        return Colors.red[(i + 2) * 100];
      }
    }
    return null;
  }
}