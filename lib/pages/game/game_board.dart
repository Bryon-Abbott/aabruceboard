import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/board.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_board_grid.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';

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
  late String _uid;

  late TextStyle textStyle;
  // Todo: Refactor to bring all controllers into a list (or else improve).
  late TextEditingController controller1, controller2;
  List<TextEditingController> controllers = [];

  double gridSize = gridSizeSmall;
  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  @override
  void initState() {
    game = widget.game;
    series = widget.series;
    controller1 = TextEditingController();
    controller2 = TextEditingController();

    for (int i=0; i<4; i++) {
      controllers.add(TextEditingController());
    }
    super.initState();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    for (TextEditingController c in controllers ) {
      c.dispose;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    game = widget.game;

    BruceUser bruceUser = Provider.of<BruceUser>(context);
    _uid = bruceUser.uid;

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

    dev.log("Reload Game ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:build()");
    //gameData.loadData(games.getGame(games.currentGame).gameNo!);

    textStyle = Theme.of(context).textTheme.bodySmall!
        .copyWith(color: Colors.yellow);

    return StreamBuilder<FirestoreDoc>(
        stream: DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key).fsDocStream(key: game.key),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Board board = snapshot.data! as Board;
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Bruce Board'),
                  actions: [
                    PopupMenuButton<int>(
                        onSelected: (item) => onMenuSelected(context, item, board),
                        itemBuilder: (context) =>
                        [
                          const PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                  children: [
                                    Icon(Icons.download_outlined,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Download Game Data"),
                                  ]
                              )
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                  children: [
                                    Icon(
                                        Icons.filter_list, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Fill remaining"),
                                  ]
                              )
                          ),
                          const PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                  children: [
                                    Icon(Icons.percent_outlined,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Update Splits"),
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
                                child: const Icon(Icons.sports_football_outlined,
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
                                child: GameBoardGrid(game: game, board: board, series: series)
                            ),
                          )
                        ],
                      ),
                      buildPoints(board),
                      buildScore(board),
                    ],
                  ),
                ),
              ),
            );
          } else {
            dev.log("game_test: Error ${snapshot.error}", name: '${runtimeType.toString()}:build()' );
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
            // Padding(
            //   padding: const EdgeInsets.all(2.0),
            //   child: Container(
            //     padding: const EdgeInsets.all(1.0),
            //     width: 40,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Theme.of(context).colorScheme.outline),
            //       color: Theme.of(context).colorScheme.surfaceVariant,
            //     ),
            //     child: Text((board.getBoughtSquares()*board.percentSplits[index]*game.squareValue~/100).toString(),
            //         textAlign: TextAlign.right),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                height: 25,
                width: 45,
                child: ElevatedButton(
                  child: const Text('Score'),
                  onPressed: () async {
                    dev.log("Getting Scores ... ", name: "${runtimeType.toString()}:buildScore");
                    final List<String>? score = await openDialogScores(index, board);
                    if (score == null || score.isEmpty) {
                      return;
                    } else {
                      dev.log("Loading Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:buildScore()");
                      //gameData.loadData(game.gameNo!);
                      if (score[0].isNotEmpty) {
                        board.rowResults[index] = int.parse(score[0]);
                      }
                      if (score[1].isNotEmpty) {
                        board.colResults[index] = int.parse(score[1]);
                      }

                      dev.log("Saving Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:buildScore()");
                      //gameData.saveData(game.gameNo!);
                      setState(() {
                        dev.log("setState() ...", name: "${runtimeType.toString()}:buildScore");
                      });
                    }
                  },
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
        dev.log("Menu Select 0:Download Game", name: "${runtimeType.toString()}:onMenuSelected");
//        widget.gameStorage.writeGameData(BruceArguments(players, games));
        break;
      case 1:
        // dev.log("Menu Select 1:Fill in remainder", name: "${this.runtimeType.toString()}:onMenuSelected");
        // dev.log("Filling scores-Before", name: "${this.runtimeType.toString()}:onMenuSelected");
        // dynamic playerSelected = await Navigator.pushNamed(
        //     context, '/manageplayers',
        //     arguments: BruceArguments(players, games));
        // if (playerSelected != null) {
        //   dev.log("Load Game Data ... GameNo: ${game.gameNo} ", name: "${this.runtimeType.toString()}:onMenuSelected");
        //   // gameData.loadData(games.getGame(games.currentGame).gameNo!);
        //   int updated = 0;
        //   for (int i = 0; i < 100; i++) {
        //     if (gameData.boardData[i] == -1) {
        //       gameData.boardData[i] = (playerSelected as Player)
        //           .playerNo!; // set to the first player.:);
        //       updated++;
        //     }
        //   }
        //   dev.log("Saving Game Data ... Game Board ${game.gameNo}, Squares $updated", name: "${this.runtimeType.toString()}:onMenuSelected");
        //   gameData.saveData(game.gameNo!);
        //   setState(() { });
        // } else {
        //   dev.log("Return value was null", name: "${this.runtimeType.toString()}:onMenuSelected");
        // }
        break;
      case 2:
        int qtrPercents = 0;
        dev.log("Menu Select 2:Update Splits", name: "${runtimeType.toString()}:onMenuSelected");
        final List<String>? percents = await openDialogSplits(board);
        if (percents == null || percents.isEmpty) {
          return;
        } else {
          dev.log("Loading Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:buildScore");
          for (int i=0; i<4; i++) {
            if (percents[i].isNotEmpty) {
              board.percentSplits[i] = int.parse(percents[i]);
            }
            qtrPercents += board.percentSplits[i];
            dev.log("Split Data ... '${percents[i]}' ", name: "${runtimeType.toString()}:buildScore");
          }
          board.percentSplits[4] = 100 - qtrPercents;
          dev.log("Split Data ... GameNo: ${game.docId}, Qtr Splits: $qtrPercents,  Total Splits: ${board.percentSplits[4]}", name: "${runtimeType.toString()}:buildScore");

          dev.log("Saving Game Data ... GameNo: ${game.docId}", name: "${runtimeType.toString()}:buildScore");
          DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
              .fsDocUpdate(board); // ToDo: Fix this.
          setState(() {
            dev.log("setState() ...", name: "${runtimeType.toString()}:buildScore");
          });
        }
        break;
    }
  }

  Future<List<String>?> openDialogScores(int qtr, Board board) =>
      showDialog<List<String>>(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(6,2,2,2),
          actionsPadding: const EdgeInsets.all(2),
          contentPadding: const EdgeInsets.fromLTRB(6,2,6,2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0)
          ),
          title: Text("Quarter ${qtr + 1} Score"),
          titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          contentTextStyle: Theme.of(context).textTheme.bodyLarge,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: game.teamOne),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: controller1,
                onSubmitted: (_) => submitScores(),
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: game.teamTwo),
                style: Theme.of(context).textTheme.bodyMedium,
                controller: controller2,
                onSubmitted: (_) => submitScores(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: submitScores,
              child: const Text('Save'),
            ),
          ],
        ),
      ); // end _GameBoard:showDialog()

  void submitScores() {
    Navigator.of(context).pop([controller1.text, controller2.text]);
    controller1.clear();
    controller2.clear();
  } // End _GameBoard:submit()

  Future<List<String>?> openDialogSplits(Board board) => showDialog<List<String>>(
    context: context,
    builder: (context) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(6,2,2,2),
      actionsPadding: const EdgeInsets.all(2),
      contentPadding: const EdgeInsets.fromLTRB(6,2,6,2),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0)
      ),
      title: const Text("Quarterly Percentage Splits"),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
      contentTextStyle: Theme.of(context).textTheme.bodyLarge,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(4, (index) {
          controllers[index].value = TextEditingValue(text: board.percentSplits[index].toString());
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              width: 300,
              child: TextField(
                    //maxLength: 100,
                    autofocus: true,
                    decoration: InputDecoration(
                      label: Text("Qtr ${index+1}"),
                      hintText: "Qtr${index + 1}",
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    controller: controllers[index],
                    onSubmitted: (_) => submitSplits(),
                  ),
              ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: submitSplits,
          child: const Text('Save'),
        ),
      ],
    ),
  ); // end _GameBoard:showDialog()

  void submitSplits() {
    Navigator.of(context).pop(List.generate(4, (i) => controllers[i].text));
    for (var c in controllers) {
      c.clear();
    }
  } // End _GameBoard:submit()

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

    // // Get column and row indexes for given score digit
    // int row = gameData.rowScores.indexOf(lastDigitTwo);
    // int col = gameData.colScores.indexOf(lastDigitOne);
    // dev.log("Row : $row Col: $col", name: "${runtimeType.toString()}:getWinner");
    //
    // if (col == -1 || row == -1) return "Lock scores";
    // // log("Row : Col are $row : $col",name: 'GameBoard');
    //
    // // Find the player number on the board
    // int playerNo = gameData.boardData[row * 10 + col];
    //
    // // If no player assigned to board return No Player
    // if (playerNo == -1) return "Not picked";
    //
    // // if the playerNo cant be found return Player not found (should never happen) else return name.
    // // String displayName = players.searchPlayer(playerNo)?.fName ?? "??? $playerNo";
    // // displayName += " ";
    // // displayName += players.searchPlayer(playerNo)?.lName ?? "??? $playerNo";
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
                        child: Text('Fix Me'),
                        // child: Text((board.getBoughtSquares()*board.percentSplits[index]*game.squareValue~/100).toString(),
                        //     textAlign: TextAlign.right),
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
                            child: Text('Fix Me'),
                            // child: Text((board.getBoughtSquares()*game.squareValue).toString(),
                            //     textAlign: TextAlign.right),
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
