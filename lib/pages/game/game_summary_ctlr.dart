part of 'game_summary_page.dart';

abstract class GameSummaryCtlr extends State<GameSummaryPage> {
  late Game game;
  late Grid grid;

  @override
  void initState() {
    game = widget.game;
    grid = widget.grid;

    super.initState();
  }

  Future<List<Player>> getPlayers(List<int> playerNos) async {
    List<Player> players = [];
    for (int pNo=0; pNo < playerNos.length; pNo++ ) {
      Player player = await DatabaseService(FSDocType.player).fsDoc(docId: playerNos[pNo]) as Player;
      players.add(player);
      log("Found Player ${player.fName} ${player.lName} ", name: "${runtimeType.toString()}:getNames");
      }
    return players;
  } // End _GameBoard:getWinners
}