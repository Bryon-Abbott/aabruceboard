import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';
import 'package:bruceboard/utils/downloadgame.dart';
import 'package:flutter/material.dart';
import 'package:bruceboard/utils/brucearguments.dart';
import 'package:bruceboard/utils/games.dart';
import 'package:bruceboard/utils/players.dart';
const double gridSizeLarge = 1000;
const double gridSizeSmall = 500;
// ===========================================================================
// Desc: Create the main GameBoard screen and necessary widgets and member
// functions.
// ----------
// NOTES:
// The resizing of the screen is costly from a loading data perspective
// as the data is loaded twice everytime the screen size is changed. This
// will have minimal impact on Mobile instances but is costly for Web and
// desktop apps.
// ----------
// 2023/09/18 Bryon   Created
// ===========================================================================
class GameBoard extends StatefulWidget {
//  const GameBoard({super.key});
  const GameBoard({super.key, required this.gameStorage});

  final DownloadGame gameStorage;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late Game game;
  late Games games;
  late Players players;
  late TextStyle textStyle;
  late TextEditingController controller1, controller2;

  List<TextEditingController> controllers = [];

  double gridSize = gridSizeSmall;
  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  GameData gameData = GameData();

  @override
  void initState() {
    super.initState();
    controller1 = TextEditingController();
    controller2 = TextEditingController();

    for (int i=0; i<4; i++) {
      controllers.add(TextEditingController());
    }

  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    players = Players();
    games = Games();
    game = games.getGame(games.currentGame);

    // Calculate screen size
    var padding = MediaQuery.of(context).padding;
    screenHeight = MediaQuery.of(context).size.height - padding.top - padding.bottom;
    screenWidth = MediaQuery.of(context).size.width - padding.left - padding.right;

    // Dynamically adjust the grid size for Small:Phone / Large:Web,Tablet, etc
    if (screenWidth > 1000) {
      gridSize = gridSizeLarge;
    } else {
      gridSize = gridSizeSmall;
    }

    dev.log("Reload Game ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:build");
    gameData.loadData(games.getGame(games.currentGame).gameNo!);

    textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.yellow);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bruce Board'),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onMenuSelected(context, item),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(
                    value: 0,
                      child: Row(
                          children: [
                            Icon(Icons.download_outlined, color: Colors.white),
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
                            Icon(Icons.filter_list, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Fill remaining"),
                          ]
                      )
                  ),
                  const PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                          children: [
                            Icon(Icons.percent_outlined, color: Colors.white),
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
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Colors.amber[900],
                        // ),
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
                      width: min(screenWidth - 48, gridSize-4),
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
                      height: max(min(screenHeight - 308, gridSize-4), 100), // not less than 100
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
                    behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: const Center(
                        // child: BoardGrid(args: BruceArguments(players, games))
                        child: BoardGrid()
                    ),
                  )
                ],
              ),
//              buildPoints(newScreenWidth),
              buildPoints(),
//              buildScore(newScreenWidth),
              buildScore(),
            ],
          ),
        ),
      ),
    );
  } // end _GameBoard:build()

  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the scores, update quarterly
  // results and display winners.
  // --------------------------------------------------------------------------
//  Widget buildScore(double newScreenWidth) {
  Widget buildScore() {
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
                child: Text(gameData.quarterlyResults[index].toString(),
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
                child: Text(gameData.quarterlyResults[index + 4].toString(),
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
                child: Text(getWinners(gameData.quarterlyResults[index],
                    gameData.quarterlyResults[index + 4], gameData, players)),
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
                child: Text((gameData.getBoughtSquares()*gameData.percentSplits[index]*game.squareValue~/100).toString(),
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
                  onPressed: () async {
                    dev.log("Getting Scores ... ", name: "${runtimeType.toString()}:buildScore");
                    final List<String>? score = await openDialogScores(index);
                    if (score == null || score.isEmpty) {
                      return;
                    } else {
                      dev.log("Loading Game Data ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:buildScore");
                      gameData.loadData(game.gameNo!);
                      if (score[0].isNotEmpty) {
                        gameData.quarterlyResults[index] =
                            int.parse(score[0]);
                      }
                      if (score[1].isNotEmpty) {
                        gameData.quarterlyResults[index + 4] =
                            int.parse(score[1]);
                      }
                      dev.log("Saving Game Data ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:buildScore");
                      gameData.saveData(game.gameNo!);
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
  void onMenuSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        dev.log("Menu Select 0:Download Game", name: "${runtimeType.toString()}:onMenuSelected");
        widget.gameStorage.writeGameData(BruceArguments(players, games));
        break;
      case 1:
        dev.log("Menu Select 1:Fill in remainder", name: "${runtimeType.toString()}:onMenuSelected");
        dev.log("Filling scores-Before", name: "${runtimeType.toString()}:onMenuSelected");
        dynamic playerSelected = await Navigator.pushNamed(
            context, '/manageplayers',
            arguments: BruceArguments(players, games));
        if (playerSelected != null) {
          dev.log("Load Game Data ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:onMenuSelected");
          gameData.loadData(games.getGame(games.currentGame).gameNo!);
          int updated = 0;
          for (int i = 0; i < 100; i++) {
            if (gameData.boardData[i] == -1) {
              gameData.boardData[i] = (playerSelected as Player)
                  .playerNo!; // set to the first player.:);
              updated++;
            }
          }
          dev.log("Saving Game Data ... Game Board ${game.gameNo}, Squares $updated", name: "${runtimeType.toString()}:onMenuSelected");
          gameData.saveData(game.gameNo!);
          setState(() { });
        } else {
          dev.log("Return value was null", name: "${runtimeType.toString()}:onMenuSelected");
        }
        break;
      case 2:
        int qtrPercents = 0;
        dev.log("Menu Select 2:Update Splits", name: "${runtimeType.toString()}:onMenuSelected");
        final List<String>? percents = await openDialogSplits();
        if (percents == null || percents.isEmpty) {
          return;
        } else {
          dev.log("Loading Game Data ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:buildScore");
          gameData.loadData(game.gameNo!);

          for (int i=0; i<4; i++) {
            if (percents[i].isNotEmpty) {
              gameData.percentSplits[i] = int.parse(percents[i]);
            }
            qtrPercents += gameData.percentSplits[i];
            dev.log("Split Data ... '${percents[i]}' ", name: "${runtimeType.toString()}:buildScore");
          }
          gameData.percentSplits[4] = 100 - qtrPercents;
          dev.log("Split Data ... GameNo: ${game.gameNo}, Qtr Splits: $qtrPercents,  Total Splits: ${gameData.percentSplits[4]}", name: "${runtimeType.toString()}:buildScore");

          dev.log("Saving Game Data ... GameNo: ${game.gameNo}", name: "${runtimeType.toString()}:buildScore");
          gameData.saveData(game.gameNo!);
          setState(() {
            dev.log("setState() ...", name: "${runtimeType.toString()}:buildScore");
          });
        }
        break;
    }
  }

  Future<List<String>?> openDialogScores(int qtr) => showDialog<List<String>>(
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

  Future<List<String>?> openDialogSplits() => showDialog<List<String>>(
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
          controllers[index].value = TextEditingValue(text: gameData.percentSplits[index].toString());
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

  String getWinners(int scoreOne, int scoreTwo, GameData gameData, Players players) {
    //log("Scores are $scoreOne : $scoreTwo",name: 'GameBoard');

    // If score is not set yet return TBD
    //dev.log("Score One : $scoreOne Score two: $scoreTwo", name: "${this.runtimeType.toString()}:getWinner");

    if (scoreOne == -1 || scoreTwo == -1) return "Enter Score";

    // Get last diget of each score
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

    // If no player assiged to board return No Player
    if (playerNo == -1) return "Not picked";

    // if the playerNo cant be found return Player not found (should never happen) else return name.
    String displayName = players.searchPlayer(playerNo)?.fName ?? "??? $playerNo";
    displayName += " ";
    displayName += players.searchPlayer(playerNo)?.lName ?? "??? $playerNo";
    return displayName;
  } // End _GameBoard:getWinners

  // --------------------------------------------------------------------------
  // _GameBoard member functions to display the points and point distribution
  // --------------------------------------------------------------------------
  // Widget buildPoints(double newScreenWidth) {
  Widget buildPoints() {
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
                        child: Text((gameData.getBoughtSquares()*gameData.percentSplits[index]*game.squareValue~/100).toString(),
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
                            child: Text((gameData.getBoughtSquares()*game.squareValue).toString(),
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
  //late BruceArguments args;

  // BoardGrid({Key? key, required this.args}) : super(key: key);
  const BoardGrid({Key? key}) : super(key: key);

  @override
  State<BoardGrid> createState() => _BoardGridState();
} // End BoardGrid:

class _BoardGridState extends State<BoardGrid> {
  // double squareBoxSize = 30;

  late TextStyle textStyle;
  late Game game;
  late Games games;
  late GameData gameData;
  late Players players;

  double screenWidth = gridSizeSmall; // Defaults value
  double screenHeight = gridSizeSmall; // Defaults value

  double gridSize = 500;

  @override
  void initState() {
    super.initState();
    // games = widget.args.games;
    // players = widget.args.players;
    games = Games();
    players = Players();
    game = games.getGame(games.currentGame);
    dev.log("Initialize default GameData data.", name: "${runtimeType.toString()}:initState");
    gameData = GameData();
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

    dev.log("Reloading Data ... gameNo: ${game.gameNo}", name: "${runtimeType.toString()}:build");
    gameData.loadData(games.getGame(games.currentGame).gameNo!);


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
    grid.add(NumberButton());
    for (int col = 0; col < 10; col++) {
      grid.add(ScoreButton(col, gameData.colScores));
    }
    for (int row = 0; row < 10; row++) {
      grid.add(ScoreButton(row, gameData.rowScores));
      for (int col = 0; col < 10; col++) {
        grid.add(GameButton(row * 10 + col));
      }
    }
    return grid;
  }

  Widget NumberButton() {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        onPressed: (gameData.getFreeSquares() != 0 || gameData.scoresLocked)
            ? null
            :
        //onPressed: (gameData.getFreeSquares() != 0) ? null :
            () {
          if (gameData.getFreeSquares() == 0) {
            setState(() {
              dev.log("Pressed Number button", name: "${runtimeType.toString()}:NumberButton");
              gameData.setScores();
              dev.log("saving Data ... gameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:NumberButton");
              gameData.saveData(games.getGame(games.currentGame).gameNo!);
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
        child: (gameData.getFreeSquares() != 0 )
          ? Text(gameData.getFreeSquares().toString())
          : gameData.scoresLocked
            ? const Icon(Icons.lock_outline, color: Colors.red)
            : const Icon(Icons.lock_open_rounded, color: Colors.green),
      ),
    );
  }

  Widget ScoreButton(int scoreIndex, List<int> scores) {
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

  Widget GameButton(int squareIndex) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          disabledBackgroundColor: getSquareColor(squareIndex),
        ),
        onPressed: (gameData.boardData[squareIndex] == -1) ? () async {
          dev.log("Pressed game button ($squareIndex)", name: "${runtimeType.toString()}:GameButton");
          dynamic playerSelected = await Navigator.pushNamed(
              context, '/manageplayers',
              arguments: BruceArguments(players, games));
          if (playerSelected == null) {
            dev.log("No Player Selected", name: "${runtimeType.toString()}:GameButton");
          } else {
            setState(() {
              Player p = playerSelected as Player;
              dev.log("Player Selected (${p.initials}) as Player)", name: "${runtimeType.toString()}:GameButton");
              gameData.boardData[squareIndex] = p.playerNo!;
              // Save Updates
              // String x = this.context.widget.runtimeType;
              // String t = this.runtimeType.toString();
              dev.log("saving Data ... gameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:GameButton");
              gameData
                  .saveData(games.getGame(games.currentGame).gameNo!);
            });
          }
        } : null,
        child: (gameData.boardData[squareIndex] == -1)
            ? const Text("FS")
            : Text(players.searchPlayer(gameData.boardData[squareIndex])?.initials
            ?? "??",
        ),
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
    if (gameData.rowScores[row] == -1 || gameData.colScores[col] == -1) {
      return null;
    }

    for (int i = 3; i >= 0; i--) {
      if (gameData.quarterlyResults[i] == -1 ||
          gameData.quarterlyResults[i + 4] == -1) continue;
      // Get last diget of each score
      lastDigitOne =
          gameData.quarterlyResults[i] % 10; // Column Number = Team one
      lastDigitTwo =
          gameData.quarterlyResults[i + 4] % 10; // Row Number = Team two
      // Check if both are equal
      if ((gameData.colScores[col] == lastDigitOne) &&
          gameData.rowScores[row] == lastDigitTwo) {
        return Colors.red[(i + 2) * 100];
      }
    }
    return null;
  }
} // End _BoardGrid: