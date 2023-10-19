import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bruceboard/utils/preferences.dart';

// ==========
// Desc: Create helper classes and extensions for games
// ----------
// 2023/09/14 Bryon   Created
// ==========
// Extend list Class to add moveup and movedown to
// allow changing of player order
extension MoveElement<T> on List<T> {
  void moveup(int index) {
    if (index > 0) {
      var element = this[index - 1];
      this[index - 1] = this[index];
      this[index] = element;
    }
  }

  void movedown(int index) {
    if (index < length - 1) {
      var element = this[index + 1];
      this[index + 1] = this[index];
      this[index] = element;
    }
  }
}

// ==========
// Class to hold and manages GameData
// ==========
class GameData {
  //List<int> axisScores = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
  List<int> boardData = List<int>.filled(100, -1);
  // Todo: splist the axis back to TeamOne and TeamTwo
  //List<int> axisScores = List<int>.filled(20, -1);
  List<int> rowScores = List<int>.filled(10, -1);
  List<int> colScores = List<int>.filled(10, -1);
  List<int> quarterlyResults = List<int>.filled(8, -1);  // Team1-Q1, Q2, Q3, Q4, Team2-Q1, Q2, Q3, Q4
  List<int> percentSplits = List<int>.filled(5, 20);     // Q1, Q2, Q3, Q4, Community
  bool scoresLocked = false;

  int getFreeSquares() {
    int free = boardData.where((e) => e == -1).length;
    dev.log("Number of free squares is $free", name: "${this.runtimeType.toString()}:getFreeSquares");
    return free;
  }

  int getPickedSquares() {
    int picked = boardData.where((e) => e != -1).length;
    dev.log("Number of picked squares is $picked", name: "${this.runtimeType.toString()}:getPickedSquares");
    return picked;
  }

  int getBoughtSquares() {
    String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ??
     "-1";  // If no perferences saved for ExcludePlayerNo, default to -1
    int excludePlayerNo = int.parse(excludePlayerNoString);

    int picked = boardData.where((e) => (e != -1) && (e != excludePlayerNo)).length;
    dev.log("Number of picked squares is $picked", name: "${this.runtimeType.toString()}:getPickedSquares");
    return picked;
  }

  // Set the values of the score cells for the x and y axes
  void setScores() {
    List<int> scores = [];

    scores = [0,1,2,3,4,5,6,7,8,9];
    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      rowScores[i] = scores.removeAt(pick);
    }
    scores = [0,1,2,3,4,5,6,7,8,9];
    for (int i=0; i<10; i++) {
      int pick = Random().nextInt(scores.length);
      colScores[i] = scores.removeAt(pick);
    }
    scoresLocked = true;
  }

  // Load game data from persistent data
  Future<void> loadData(int gameNo) async {
    String jsonString = "";

    // Retrieve Board Data
    var intFormat = NumberFormat("B000000", "en_US");
    String boardKey = intFormat.format(gameNo);
    jsonString = Preferences.getPreferenceString(boardKey) ??
        List<int>.filled(100, -1).toString();
    List<dynamic> boardDataDynamic =jsonDecode(jsonString);
    boardData = List<int>.from(boardDataDynamic);

    // Retrieve Score Data
    intFormat = NumberFormat("R000000", "en_US");
    String rowScoreKey = intFormat.format(gameNo);
    jsonString = Preferences.getPreferenceString(rowScoreKey) ??
        List<int>.filled(10, -1).toString();
    List<dynamic> rowScoresDynamic =jsonDecode(jsonString);
    rowScores = List<int>.from(rowScoresDynamic);

    // Retrieve Score Data
    intFormat = NumberFormat("C000000", "en_US");
    String colScoreKey = intFormat.format(gameNo);
    jsonString = Preferences.getPreferenceString(colScoreKey) ??
        List<int>.filled(10, -1).toString();
    List<dynamic> colScoresDynamic =jsonDecode(jsonString);
    colScores = List<int>.from(colScoresDynamic);

    // Retrieve Quarterly Score Data
    intFormat = NumberFormat("Q000000", "en_US");
    String quarterlyResultsKey = intFormat.format(gameNo);
    jsonString = Preferences.getPreferenceString(quarterlyResultsKey) ??
        List<int>.filled(8, -1).toString();
    List<dynamic> quarterlyScoreDynamic =jsonDecode(jsonString);
    quarterlyResults = List<int>.from(quarterlyScoreDynamic);

    // Retrieve Split Percent Data
    intFormat = NumberFormat("P000000", "en_US");
    String percentKey = intFormat.format(gameNo);
    jsonString = Preferences.getPreferenceString(percentKey) ??
        List<int>.filled(5, 20).toString();
    List<dynamic> percentSplitDynamic =jsonDecode(jsonString);
    percentSplits = List<int>.from(percentSplitDynamic);

    // Check if Row Scores and Col Scores are set, if so lock them.
    if (rowScores[0] == -1 || colScores == -1) {
      scoresLocked = false;
    } else {
      scoresLocked = true;
    }
  }

  // Save players from persistent data when user modifies
  Future<void> saveData(int gameNo) async {
    String jsonString = "";

    // Store Board Data
    var intFormat = NumberFormat("B000000", "en_US");
    String boardKey = intFormat.format(gameNo);
    jsonString = jsonEncode(boardData);
    Preferences.setPreferenceString(boardKey, jsonString);

    // Store Score Data - Row
    intFormat = NumberFormat("R000000", "en_US");
    String rowScoreKey = intFormat.format(gameNo);
    jsonString = jsonEncode(rowScores);
    Preferences.setPreferenceString(rowScoreKey, jsonString);

    // Store Score Data - Col
    intFormat = NumberFormat("C000000", "en_US");
    String colScoreKey = intFormat.format(gameNo);
    jsonString = jsonEncode(colScores);
    Preferences.setPreferenceString(colScoreKey, jsonString);

    // Store Quarterly Results Data
    intFormat = NumberFormat("Q000000", "en_US");
    String quarterlyResultsKey = intFormat.format(gameNo);
    jsonString = jsonEncode(quarterlyResults);
    Preferences.setPreferenceString(quarterlyResultsKey, jsonString);

    // Store Percent Splits Data
    intFormat = NumberFormat("P000000", "en_US");
    String percentSplitsKey = intFormat.format(gameNo);
    jsonString = jsonEncode(percentSplits);
    Preferences.setPreferenceString(percentSplitsKey, jsonString);
  }
}


// Player class encapsulates a player
// stores scores and status for the current game
// If player is added without a playerNo it is a NEW player so add the number.
class Game {
  int? gameNo =-1;
  String name = "";
  String owner = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";

  Game({this.gameNo, required this.name, required this.owner, required this.squareValue, required this.teamOne, required this.teamTwo})
  {
    // If playerNo is null, assume creating a new player so create a number.
    if (gameNo == null) {
      // Use local variable avoid null assertion (!)
      //https://stackoverflow.com/questions/66468181/how-to-use-the-null-assertion-operator-with-instance-fields
      int nextNo = Preferences.getGameNextNo();
      gameNo = nextNo;
      Preferences.setGameNextNo(nextNo+1); // Save the Player Next Number
      GameData gameData = GameData();
      gameData.saveData(gameNo!);
    }
  } // Named named in { }
// Player(){
//   name = 'To be Determined';
// }
}
// Games class to hold list of players
class Games {
  static final Games _games = Games._internal();
  List<Game> games = [];
  int currentGame = -1;

  factory Games() {
    return _games;
  }

  Games._internal() {
    dev.log("Instanciating Games ... ");
  }

  // Constructor
  // Games();


  // Load players from persistent data
  Future<void> loadGames() async {
    //String jsonString = "";
    final prefs = await SharedPreferences.getInstance();
    // Ensure the Free player is in the player list.
    // Todo: move this to the (AA) preferences class
    String jsonString = prefs.getString("key-games") ??
        '[{"gameNo": 1000, "name": "Edit Game", "owner": "me", "squareValue": 0, "teamOne": "Team One", "teamTwo": "Team Two"}]';
    List<dynamic> gamesData = jsonDecode(jsonString);

    // final playerNames = prefs.getStringList('Players') ?? [];
    // print("Loading Players : Players Names Length ${playerNames.length}");
    games.clear();
    for (int i = 0; i < gamesData.length; i++) {
      games.add(
          Game(
            gameNo:      gamesData[i]['gameNo']       ?? 0,
            name:        gamesData[i]['name']         ?? "Error Loading Shared Data",
            owner:       gamesData[i]['owner']        ?? "",
            squareValue: gamesData[i]['squareValue']  ?? 0,
            teamOne:     gamesData[i]['teamOne']      ?? "",
            teamTwo:     gamesData[i]['teamTwo']      ?? ""
          )
      );
    }
  }

  // Save players from persistent data when user modifies
  Future<void> saveGames() async {
    List<dynamic> gamesData = [];
    // Todo: move this to the (AA) preferences class
    final prefs = await SharedPreferences.getInstance();
    // print("Saving Player: Player Length ${players.length}");
    for (int i = 0; i < games.length; i++) {
      Map<String, dynamic> g = {
        "gameNo":       games[i].gameNo,
        "name":         games[i].name,
        "owner":        games[i].owner,
        "squareValue":  games[i].squareValue,
        "teamOne":      games[i].teamOne,
        "teamTwo":      games[i].teamTwo
      };
      gamesData.add(g);
    }
    await prefs.setString('key-games', jsonEncode(gamesData)); //?? [];
  }

  Game getGame(int index) {
    return games[index];
  }

  void addGame(String newGame, String newOwner, int newSquareValue, String newTeamOne, String newTeamTwo) {
    games.add(Game(name: newGame, owner: newOwner, squareValue: newSquareValue, teamOne: newTeamOne, teamTwo: newTeamTwo));
  }

  void delGame(int gameIndex) {
    games.removeAt(gameIndex);
  }

  void moveup(int index) {
    games.moveup(index);
  }

  void movedown(int index) {
    games.movedown(index);
  }

  // Reset game in preparation for a new game.
  // void reset(int index) {
  // }
}
