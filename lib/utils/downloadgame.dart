import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:bruceboard/utils/brucearguments.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bruceboard/utils/games.dart';
import 'package:bruceboard/utils/players.dart';


class DownloadGame {
  late Game game;
  late Games games;
  late Players players;

  Future<String> get _localPath async {
    //final directory = await getApplicationDocumentsDirectory();
    // If download exist, store bruceboard data here, else store in docs directory.
    Directory directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final bruceDirectoryPath = join(directory.path, 'bruceboard');
    Directory bruceDirectory = Directory(bruceDirectoryPath);
    final bruceDirectoryExists = await bruceDirectory.exists();

    if (!bruceDirectoryExists) {
      log("Path does not exist $bruceDirectoryPath ... creating", name: "${runtimeType.toString()}:get _localfine");
      bruceDirectory = await Directory(bruceDirectoryPath).create(recursive: true);
    }
    return bruceDirectoryPath;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    log("Finding Path $path", name: "${runtimeType.toString()}:get _localfine");

    var intFormat = NumberFormat("G000000.txt", "en_US");
    String fileName = intFormat.format(game.gameNo);
    return File(join(path, fileName));
  }

  Future<File> writeGameData(BruceArguments args) async {
    players = args.players;
    games = args.games;
    game = games.getGame(games.currentGame);

    GameData gameData = GameData();

    String gameDataTxt;

    final file = await _localFile;
    final sink = file.openWrite();

    //String eol = Platform().lineSeparator();
    String eol = Platform.isWindows ? '\r\n' : '\n';

    // Write out Game Data
    gameDataTxt  = 'Date: ${DateTime.now().toString()}$eol';
    gameDataTxt += 'Game Number: ${game.gameNo}$eol';
    gameDataTxt += 'Name: ${game.name}$eol';
    gameDataTxt += 'Owner: ${game.owner}$eol';
    gameDataTxt += 'Team One: ${game.teamOne}$eol';
    gameDataTxt += 'Team Two: ${game.teamTwo}$eol';
    gameDataTxt += 'Square Value: ${game.squareValue}$eol';

    sink.write(gameDataTxt);
    //file.writeAsString(_gameDataTxt, mode: FileMode.write);

    // Write out Square Data
    log("Reload Game ... GameNo: ${game.gameNo} ", name: "${runtimeType.toString()}:writegameData");
    gameData.loadData(games.getGame(games.currentGame).gameNo!);

    var rowFormat = NumberFormat("R00", "en_US");
    var colFormat = NumberFormat("C00", "en_US");

    gameDataTxt = 'Score Info: $eol';
    for (int i=0; i<4; i++) {
      gameDataTxt += 'Q${i+1}: ${gameData.quarterlyResults[i]} to ${gameData.quarterlyResults[i+4]}, ';
    }
    gameDataTxt += eol;
    sink.write(gameDataTxt);

    gameDataTxt = "Square Info:$eol";
    for (int i=0; i<100; i++) {
      gameDataTxt += '${rowFormat.format(i~/10+1)}:${colFormat.format(i%10+1)}, ';
      gameDataTxt += '(${gameData.rowScores[i~/10]}:${gameData.colScores[i%10]}), ';
      gameDataTxt += 'Player: ${gameData.boardData[i]}, ';
      gameDataTxt += 'Name: ${players.searchPlayer(gameData.boardData[i])?.fName ?? "Missing FName"} '
                            '${players.searchPlayer(gameData.boardData[i])?.lName ?? "Missing LName"} ';
      gameDataTxt += 'Email: ${players.searchPlayer(gameData.boardData[i])?.email ?? "Missing Email"}, ';
      gameDataTxt += 'Phone: ${players.searchPlayer(gameData.boardData[i])?.phone ?? "Missing Phone"}$eol';
    }
    sink.write(gameDataTxt);

    // file.writeAsString(_gameDataTxt, mode: FileMode.append);

    sink.close();
    return file;
  }
}

