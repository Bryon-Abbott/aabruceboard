import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bruceboard/utils/preferences.dart';
// ==========
// Desc: Create helper classes and extensions for Players
// ----------
// 2023/09/12 Bryon   Created
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

enum Notification { email, phone}

// Player class encapsulates a player
// stores scores and status for the current game
// If player is added without a playerNo it is a NEW player so add the number.
class Player {
  int? playerNo =-1;
//  String name = "";
  String fName = "";
  String lName = "";
  String email = "";
  String initials = "";
  String phone = "";
  Notification notification = Notification.email;

  Player({this.playerNo, required this.fName, required this.lName, required this.email, required this.initials, required this.phone})
  {
    // If playerNo is null, assume creating a new player so create a number.
    if (playerNo == null) {
      // Use local variable avoid null assertion (!)
      //https://stackoverflow.com/questions/66468181/how-to-use-the-null-assertion-operator-with-instance-fields
      int nextNo = Preferences.getPlayerNextNo();
      playerNo = nextNo;
      Preferences.setPlayerNextNo(nextNo+1); // Save the Player Next Number
    }
  } // Named named in { }
// Player(){
//   name = 'To be Determined';
// }
}
// Players class to hold list of players
class Players {
  static final Players _players = Players._internal();
  List<Player> players = [];
  int currentPlayer = -1;

  factory Players() {
    return _players;
  }

  // Constructor
  //Players();
  Players._internal() {
    log("Instanciating Players ... ");
  }

  // Load players from persistent data
  Future<void> loadPlayers() async {
    //String jsonString = "";
    final prefs = await SharedPreferences.getInstance();
    // Ensure the Free player is in the player list.
    // Todo: move this to the (AA) preferences class
    String jsonString = prefs.getString("key-players") ??
        '[{"playerno": 1000, "fname": "Excluded", "lname" : "Square", "email": "null", "initials": "XX", "phone": "(999)999-9999"}]';
    List<dynamic> playersData = jsonDecode(jsonString);

    // final playerNames = prefs.getStringList('Players') ?? [];
    // print("Loading Players : Players Names Length ${playerNames.length}");
    players.clear();
    for (int i = 0; i < playersData.length; i++) {
      players.add(
          Player(
            playerNo: playersData[i]['playerno'] ?? 1000,
            fName:    playersData[i]['fname']    ?? "",
            lName:    playersData[i]['lname']    ?? "Error",
            email:    playersData[i]['email']    ?? "",
            initials: playersData[i]['initials'] ?? "",
            phone:    playersData[i]['phone']    ?? ""
          )
      );
    }
  }

  // Save players from persistent data when user modifies
  Future<void> savePlayers() async {
    List<dynamic> playersData = [];
    // Todo: move this to the (AA) preferences class
    final prefs = await SharedPreferences.getInstance();
    // print("Saving Player: Player Length ${players.length}");
    for (int i = 0; i < players.length; i++) {
      Map<String, dynamic> x = {
        "playerno": players[i].playerNo,
        "fname":    players[i].fName,
        "lname":    players[i].lName,
        "email":    players[i].email,
        "initials": players[i].initials,
        "phone":    players[i].phone
      };
      playersData.add(x);
    }
    await prefs.setString('key-players', jsonEncode(playersData)); //?? [];
  }
  // Todo: update this to allow index or playerno as parameters and refactor code
  //
  Player getPlayer(int index) {
    return players[index];
  }

  Player? searchPlayer(int playerno) {
    for (Player p in players) {
      if (p.playerNo == playerno) {
        return p;
      }
    }
    return null;
  }

  bool initialsAreUnique(int playerNo, String initials) {

    log("initialIsUnique ... Initials $initials");
    int duplicates = players.where((e) => (e.initials == initials) && (e.playerNo != playerNo)).length;
    log("Duplicates are $duplicates");
    return duplicates == 0;
  }


  void addPlayer(String newFName, String newLName, String newEmail, String newInitials, String newPhone) {
    players.add(Player(fName: newFName, lName: newLName, email: newEmail, initials: newInitials, phone: newPhone));
  }

  void delPlayer(int playerIndex) {
    players.removeAt(playerIndex);
  }

  void moveup(int index) {
    players.moveup(index);
  }

  void movedown(int index) {
    players.movedown(index);
  }

  // Reset player in preparation for a new game.
  void reset(int index) {
  }
}
