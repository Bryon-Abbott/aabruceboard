part of 'game_summary_page.dart';

abstract class GameSummaryCtlr extends State<GameSummaryPage> {
  late Series series;
  late Game game;
  late Grid grid;
  late Board board;

  late TextEditingController controller1, controller2;
  List<TextEditingController> controllers = [];
  List<Player> winnersPlayer = List<Player>.filled(4, Player(data: {}));
  List<int> winnersCommunity = List<int>.filled(4, -1);

  @override
  void initState() {
    series = widget.series;
    game = widget.game;
    grid = widget.grid;
    board = widget.board;
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

  // ==========================================================================
  Future<List<Player>> getPlayers(List<int> playerNos) async {
    List<Player> players = [];
    for (int pNo = 0; pNo < playerNos.length; pNo++) {
      Player player = await DatabaseService(FSDocType.player)
          .fsDoc(docId: playerNos[pNo]) as Player;
      players.add(player);
      log("Found Player ${player.fName} ${player.lName} ",
          name: "${runtimeType.toString()}:getNames");
    }
    return players;
  } // End _GameBoard:getWinners

  // ==========================================================================
  Future<List<String>?> openDialogScores(int qtr, Board board) =>
      showDialog<List<String>>(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
          actionsPadding: const EdgeInsets.all(2),
          contentPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
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

  // ==========================================================================
  Future<List<List>> getWinners(Board board, Player communityPlayer) async {
//  Future<List<Player>> getWinners(Board board) async {
    Grid? grid;
    List<Player> winners = List<Player>.filled(4, Player(data: {}));
    List<int> community = List<int>.filled(4, -1);
    // If score is not set yet return TBD
    //dev.log("Score One : $scoreOne Score two: $scoreTwo", name: "${this.runtimeType.toString()}:getWinner");
    for (int qtr = 0; qtr <= 3; qtr++) {
      log("$qtr:Getting Winner",
          name: "${runtimeType.toString()}:getWinner");
      if (board.colResults[qtr] == -1 || board.colResults[qtr] == -1) {
        // Don't set the winner as Result are not set
        continue; // Go to next quarter.
      } else {
        // If grid no retrieved, get it.
        grid ??= await DatabaseService(FSDocType.grid,
                uid: communityPlayer.uid, sidKey: series.key, gidKey: game.key)
            .fsDoc(key: game.key) as Grid;
        if (grid.scoresLocked == false) {
          // Don't set the winner as Scores are not set
          continue; // Go to next quarter
        } else {
          // Get last digit of each score
          int lastDigitRow =
              board.rowResults[qtr] % 10; // Row Number = Team two
          int lastDigitCol =
              board.colResults[qtr] % 10; // Column Number = Team one
          log("$qtr:Last digit Row : $lastDigitRow Last digit Col: $lastDigitCol",
              name: "${runtimeType.toString()}:getWinner");
          // Get the Row:Col of the winner.
          int row = grid.rowScores.indexOf(lastDigitRow);
          int col = grid.colScores.indexOf(lastDigitCol);
          log("$qtr:Row : $row Col: $col",
              name: "${runtimeType.toString()}:getWinner");
          // Find the player number on the board
          int playerNo = grid.squarePlayer[row * 10 + col];
          int playerCommunity = grid.squareCommunity[row * 10 + col];
          Player player = await DatabaseService(FSDocType.player)
              .fsDoc(docId: playerNo) as Player;
          winners[qtr] = player;
          community[qtr] = playerCommunity;

          log("$qtr:Player: ${player.docId}:${player.fName} ${player.lName}, Community: $playerCommunity",
              name: "${runtimeType.toString()}:getWinner");
        }
      }
      log('$qtr:Winner: ${winners[qtr]}',
          name: "${runtimeType.toString()}:getWinner");
    }
    return [winners, community];
  } // End _GameBoard:getWinners

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
  }
  // ==========================================================================
  // MENU
  void onMenuSelected(BuildContext context, int item, Board board, Series series, Player activePlayer, Player communityPlayer) async {
    switch (item) {
      case 0:
        log("Menu Select 0:Distribute Credits", name: "${runtimeType.toString()}:onMenuSelected");
        // Verify all winners are set.
        for (Player p in winnersPlayer) {
          if (p.pid == -1) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All scores must be set to distribute credits"))
            );
            return;
          }
        }
        // Update Credits and Send messages.
        for (int i=0; i<4; i++) {
          Player p = winnersPlayer[i];
          int c = winnersCommunity[i];
          // Get exclude Player Number. If no preferences saved for ExcludePlayerNo, default to -1
          String? excludePlayerNoString = Preferences.getPreferenceString(Preferences.keyExcludePlayerNo) ?? "-1";
          int excludePlayerNo = int.parse(excludePlayerNoString);
          log("Got Exclude PID ($excludePlayerNo)", name: "${runtimeType.toString()}:onMenuSelected");

          // If Winner is a Player, transfer credits and send message.
          if (p.docId != excludePlayerNo)  {
            log("Start Board (${board.docId} Player (${p.docId}) Community ($c)", name: "${runtimeType.toString()}:onMenuSelected");
            Member member = await DatabaseService(FSDocType.member, cidKey: Community.Key(c))
                .fsDoc(docId: p.pid) as Member;
            log("Got Member (${member.docId})", name: "${runtimeType.toString()}:onMenuSelected");
            Community community = await DatabaseService(FSDocType.community, cidKey: Community.Key(c))
                .fsDoc(docId:winnersCommunity[i]) as Community;
            log("Got Community (${community.docId})", name: "${runtimeType.toString()}:onMenuSelected");
            int credits = board.squaresPicked*board.percentSplits[i]*game.squareValue~/100;
            int prevCredits = member.credits;
            member.credits += credits; // Add new Credits.
            DatabaseService(FSDocType.member, cidKey: Community.Key(winnersCommunity[i])).fsDocUpdate(member);
            // Send Message to user
            messageSend( 20070, messageType[MessageTypeOption.notification]!,
              playerFrom: activePlayer, playerTo: winnersPlayer[i],
              comment: "Thanks for Playing.",
              description: "You Won the Q${i+1} Score and received $credits credits. Your account was updated from $prevCredits to ${member.credits}) "
                  "Community: <${community.name}>, Owner: ${activePlayer.fName} ${activePlayer.lName}",
              data: { 'cid': community.docId, 'credits' : member.credits },
            );
          } else {
            log("Square one by 'No Player' ... ignore", name: "${runtimeType.toString()}:onMenuSelected");
          }
        }
        DatabaseService(FSDocType.board, sidKey:series.key, gidKey:Game.Key(board.docId))
            .fsDocUpdateField(key:Game.Key(board.docId), field: 'creditsDistributed', bvalue: true );

        log("Winners ${winnersPlayer[0].pid},${winnersPlayer[1].pid},${winnersPlayer[2].pid},${winnersPlayer[3].pid}");

        break;
      case 1:
        int qtrPercents = 0;
        log("Menu Select 2:Update Splits", name: "${runtimeType.toString()}:onMenuSelected");
        final List<String>? percents = await openDialogSplits(board);
        if (percents == null || percents.isEmpty) {
          return;
        } else {
          log("Loading Game Data ... GameNo: ${game.docId} ", name: "${runtimeType.toString()}:onMenuSelected");
          for (int i=0; i<4; i++) {
            if (percents[i].isNotEmpty) {
              board.percentSplits[i] = int.parse(percents[i]);
            }
            qtrPercents += board.percentSplits[i];
            log("Split Data ... '${percents[i]}' ", name: "${runtimeType.toString()}:onMenuSelected");
          }
          board.percentSplits[4] = 100 - qtrPercents;
          log("Split Data ... GameNo: ${game.docId}, Qtr Splits: $qtrPercents,  Total Splits: ${board.percentSplits[4]}", name: "${runtimeType.toString()}:onMenuSelected");

          log("Saving Game Data ... GameNo: ${game.docId}", name: "${runtimeType.toString()}:onMenuSelected");
          DatabaseService(FSDocType.board, sidKey: series.key, gidKey: game.key)
              .fsDocUpdate(board);
          setState(() {
            log("setState() ...", name: "${runtimeType.toString()}:onMenuSelected");
          });
        }
        break;

    }
  }


}
