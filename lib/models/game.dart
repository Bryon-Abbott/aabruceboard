class Game {
  final String gid; // Game ID
  final String sid; // Series ID
  final String pid; // Owner ID

  String name = "";
  int squareValue = 0;
  String teamOne = "";
  String teamTwo = "";

  Game({ required this.gid, required this.sid, required this.pid,
    required this.name,
    required this.teamOne,
    required this.teamTwo,
    required this.squareValue,
  });

  // // Getters & Setters
  // set teamOne(String team) => _teamOne=team;
  // String get teamOne => _teamOne;
  // set teamTwo(String team) => _teamTwo=team;
  // String get teamTwo => _teamTwo;
  // set squareValue(int val) => _squareValue=val;
  // int get squareValue => _squareValue;

}