import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';

import 'package:bruceboard/models/communityplayer.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:provider/provider.dart';

const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;
// ===========================================================================
// Desc: Display the GameBoard for 'Access' users (not Owner).
// ----------
// NOTES:
// Todo: Review resizing functions
// The resizing of the screen is costly from a loading data perspective
// as the data is loaded twice everytime the screen size is changed. This
// will have minimal impact on Mobile instances but is costly for Web and
// desktop apps.
// ----------
// 2024/01/07: Bryon   Created
// ===========================================================================
class GameBoardAccess extends StatefulWidget {
//  const GameBoard({super.key});
  const GameBoardAccess({super.key, required this.series, required this.game});
  final Series series;
  final Game game;

@override
  State<GameBoardAccess> createState() => _GameBoardAccessState();
}

class _GameBoardAccessState extends State<GameBoardAccess> {
  late Game game;
  late Series series;
  //late String _uid;

  late TextStyle textStyle;

  // Todo: Refactor to bring all controllers into a list (or else improve).

  double gridSize = gridSizeSmall;
  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

//  GameData gameData = GameData();

  @override
  void initState() {
    game = widget.game;
    series = widget.series;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    game = widget.game;

    CommunityPlayer communityPlayerProvider = Provider.of<CommunityPlayer>(context);
    Player communityPlayer = communityPlayerProvider.communityPlayer;

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

    dev.log("Reload Game ... GameNo: ${game.docId} GameOwner: ${communityPlayer.docId}, ${communityPlayer.fName}",  name: "${runtimeType.toString()}:build");
    //gameData.loadData(games.getGame(games.currentGame).gameNo!);

    textStyle = Theme
        .of(context)
        .textTheme
        .bodySmall!
        .copyWith(color: Colors.yellow);

    return StreamBuilder<FirestoreDoc>(
        stream: DatabaseService(
            FSDocType.board, uid: communityPlayer.uid, sidKey: series.key, gidKey: game.key)
            .fsDocStream(key: game.key),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Board board = snapshot.data! as Board;
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Bruce Board'),
                  actions: [
                    PopupMenuButton<int>(
                        onSelected: (item) =>
                            onMenuSelected(context, item, board),
                        itemBuilder: (context) =>
                        [
                          const PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                  children: [
                                    Icon(Icons.download_outlined,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Do Nothing ... "),
                                  ]
                              )
                          ),
                        ]
                    )
                  ],
                  centerTitle: true,
                  elevation: 0,
                ),
                body: SingleChildScrollView(
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
                                // style: ElevatedButton.styleFrom(
                                //   backgroundColor: Colors.amber[900],
                                // ),
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
                                child: Text(game.teamOne),
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
                              height: max(
                                  min(screenHeight - 308, gridSize - 4), 100),
                              // not less than 100
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
                                  child: Text(game.teamTwo),
                                ),
                              ),
                            ),
                          ),
                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                }),
                            child: Center(
                              // child: BoardGrid(args: BruceArguments(players, games))
                                child: BoardGrid(game: game, board: board)
                            ),
                          )
                        ],
                      ),
//              buildPoints(newScreenWidth),
                      buildPoints(board),
//              buildScore(newScreenWidth),
                      buildScore(board),
                    ],
                  ),
                ),
              ),
            );
          } else {
            dev.log("game_board_access: Error ${snapshot.error}", name: "${runtimeType.toString()}:build");
            return const Loading();
          }
        }
    );
  } // end _GameBoard:build()

  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the scores, update quarterly
  // results and display winners.
  // --------------------------------------------------------------------------
//  Widget buildScore(double newScreenWidth) {
  Widget buildScore(Board board) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        padding: const EdgeInsets.all(8.0),
        //height: 100,
        width: min(screenWidth, gridSize+42),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4.0),
//          color: Colors.amber[900],
        ),
        child: Column(
            children: List.generate(4, (index) {
          return Wrap(children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                width: 35,
                child: Text("Qtr${index + 1}:"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                padding: const EdgeInsets.all(1.0),
                width: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Text(board.rowResults[index].toString(),
                    textAlign: TextAlign.right),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                padding: const EdgeInsets.all(1.0),
                width: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Text(board.colResults[index].toString(),
                    textAlign: TextAlign.right),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(2.0),
              child: SizedBox(
                width: 35,
                child: Text("Won:"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                padding: const EdgeInsets.all(1.0),
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Text(getWinners(board.rowResults[index],
                    board.colResults[index], board)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(2.0),
              child: SizedBox(
                width: 35,
                child: Text("Pts:"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                padding: const EdgeInsets.all(1.0),
                width: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Text((board.getBoughtSquares()*board.percentSplits[index]*game.squareValue~/100).toString(),
                    textAlign: TextAlign.right),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 25,
                width: 45,
                child: ElevatedButton(
                  child: const Text('Score'),
                  onPressed: () async { }, // Do Nothing ...
                ),
              ),
            ),
          ]);
        }) +
            [
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                      });
                    },
                    child: const Text("Update")),
              ],)
            ]
        ),
      ),
    );
  } // end _gameBoard:buildScore()

  // --------------------------------------------------------------------------
  // Helper Functions
  // --------------------------------------------------------------------------
  void onMenuSelected(BuildContext context, int item, Board board) async {
    switch (item) {
      case 0:
        dev.log("Menu Select 0:Do Nothing ... ", name: "${runtimeType.toString()}:onMenuSelected");
        break;
    }
  }

  String getWinners(int scoreOne, int scoreTwo, Board gameData) {
    //log("Scores are $scoreOne : $scoreTwo",name: 'GameBoard');

    // If score is not set yet return TBD
    //dev.log("Score One : $scoreOne Score two: $scoreTwo", name: "${this.runtimeType.toString()}:getWinner");

    if (scoreOne == -1 || scoreTwo == -1) return "Enter Score";

    // Get last digit of each score
    int lastDigitOne = scoreOne % 10; // Column Number = Team one
    int lastDigitTwo = scoreTwo % 10; // Row Number = Team two
    dev.log("Last digit One : $lastDigitOne Last digit two: $lastDigitTwo", name: "${runtimeType.toString()}:getWinner");

    //log("Last Digits are $lastDigitOne : $lastDigitTwo",name: 'GameBoard');

    // Get column and row indexes for given score digit
    int row = gameData.rowScores.indexOf(lastDigitTwo);
    int col = gameData.colScores.indexOf(lastDigitOne);
    dev.log("Row : $row Col: $col", name: "${runtimeType.toString()}:getWinner");

    if (col == -1 || row == -1) return "Lock scores";
    // log("Row : Col are $row : $col",name: 'GameBoard');

    // Find the player number on the board
    int playerNo = gameData.boardData[row * 10 + col];

    // If no player assigned to board return No Player
    if (playerNo == -1) return "Not picked";
    String displayName = "To Be Determined";
    return displayName;
  } // End _GameBoard:getWinners
  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the points and point distribution
  // --------------------------------------------------------------------------
  // Widget buildPoints(double newScreenWidth) {
  Widget buildPoints(Board board) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        padding: const EdgeInsets.all(8.0),
        width: min(screenWidth, gridSize+42),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(4.0),
       //   color: Colors.amber[900],
        ),
        child: Wrap(
          spacing: 2,
          children:
            List.generate(5, (index) {
              return SizedBox(
                width: 80,
                child: Row(
                  children: [
                    Text((index < 4) ? "Qtr${index+1}:" : "Com:"),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        padding: const EdgeInsets.all(1.0),
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Text((board.getBoughtSquares()*board.percentSplits[index]*game.squareValue~/100).toString(),
                            textAlign: TextAlign.right),
                      ),
                    ),
                  ],
                ),
              );
            }) +
                [
                  SizedBox(
                    width: 90,
                    child: Row(
                      children: [
                        const Text("Total:"),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            padding: const EdgeInsets.all(1.0),
                            width: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.outline),
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                            child: Text((board.getBoughtSquares()*game.squareValue).toString(),
                                textAlign: TextAlign.right),
                          ),
                        ),
                      ],
                    ),
                  )
                ]
        ),
      ),
    );
  }
} // End _GameBoard:

// ============================================================================
// Board Grid Widget that provide the functions necessary to manage the
// Selection of squares and renumbering of Row/Column numbers
// ============================================================================
class BoardGrid extends StatefulWidget {
  const BoardGrid({super.key, required this.game, required this.board}); // : super(key: key);
  final Game game;
  final Board board;

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  late TextStyle textStyle;
  late Game game;
  late Board board;

  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  double gridSize = 500;

  @override
  void initState() {
    super.initState();
    game = widget.game;
    dev.log("Initialize default GameData data.", name: "${runtimeType.toString()}:initState()");
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
    dev.log("Reloading Data ... gameNo: ${game.docId}", name: "${runtimeType.toString()}:build()");

    return SizedBox(
      height: max(min(screenHeight - 308, gridSize-1), 100),
      width: min(screenWidth - 45, gridSize-1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            height: gridSize,  // These determine the Size of the buttons (~x/11)
            width: gridSize,
            child: GridView.count(
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
        onPressed: () {}, // Do Nothing ...
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
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
        onPressed: (scores[scoreIndex]) == -1 ? null : () {}, // Do Nothing ...
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
        onPressed: (board.boardData[squareIndex] == -1) ? () async {
          dev.log("Pressed game button ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
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
} // End _BoardGrid: