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
    Directory bruceDirectory = await Directory(bruceDirectoryPath);
    final bruceDirectoryExists = await bruceDirectory.exists();

    if (!bruceDirectoryExists) {
      log("Path does not exist ${bruceDirectoryPath} ... creating", name: "${this.runtimeType.toString()}:get _localfine");
      bruceDirectory = await Directory(bruceDirectoryPath).create(recursive: true);
    }
    return bruceDirectoryPath;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    log("Finding Path ${path}", name: "${this.runtimeType.toString()}:get _localfine");

    var intFormat = NumberFormat("G000000.txt", "en_US");
    String fileName = intFormat.format(game.gameNo);
    return File(join(path, fileName));
  }

  Future<File> writeGameData(BruceArguments args) async {
    players = args.players;
    games = args.games;
    game = games.getGame(games.currentGame);

    GameData _gameData = GameData();

    String _gameDataTxt;

    final file = await _localFile;
    final sink = file.openWrite();

    //String eol = Platform().lineSeparator();
    String eol = Platform.isWindows ? '\r\n' : '\n';

    // Write out Game Data
    _gameDataTxt  = 'Date: ${DateTime.now().toString()}${eol}';
    _gameDataTxt += 'Game Number: ${game.gameNo}${eol}';
    _gameDataTxt += 'Name: ${game.name}${eol}';
    _gameDataTxt += 'Owner: ${game.owner}${eol}';
    _gameDataTxt += 'Team One: ${game.teamOne}${eol}';
    _gameDataTxt += 'Team Two: ${game.teamTwo}${eol}';
    _gameDataTxt += 'Square Value: ${game.squareValue}${eol}';

    sink.write(_gameDataTxt);
    //file.writeAsString(_gameDataTxt, mode: FileMode.write);

    // Write out Square Data
    log("Reload Game ... GameNo: ${game.gameNo} ", name: "${this.runtimeType.toString()}:writegameData");
    _gameData.loadData(games.getGame(games.currentGame).gameNo!);

    var rowFormat = NumberFormat("R00", "en_US");
    var colFormat = NumberFormat("C00", "en_US");

    _gameDataTxt = 'Score Info: ${eol}';
    for (int i=0; i<4; i++) {
      _gameDataTxt += 'Q${i+1}: ${_gameData.quarterlyResults[i]} to ${_gameData.quarterlyResults[i+4]}, ';
    }
    _gameDataTxt += '$eol';
    sink.write(_gameDataTxt);

    _gameDataTxt = "Square Info:${eol}";
    for (int i=0; i<100; i++) {
      _gameDataTxt += '${rowFormat.format(i~/10+1)}:${colFormat.format(i%10+1)}, ';
      _gameDataTxt += '(${_gameData.rowScores[i~/10]}:${_gameData.colScores[i%10]}), ';
      _gameDataTxt += 'Player: ${_gameData.boardData[i]}, ';
      _gameDataTxt += 'Name: ${players.searchPlayer(_gameData.boardData[i])?.fName ?? "Missing FName"} '
                            '${players.searchPlayer(_gameData.boardData[i])?.lName ?? "Missing LName"} ';
      _gameDataTxt += 'Email: ${players.searchPlayer(_gameData.boardData[i])?.email ?? "Missing Email"}, ';
      _gameDataTxt += 'Phone: ${players.searchPlayer(_gameData.boardData[i])?.phone ?? "Missing Phone"}${eol}';
    }
    sink.write(_gameDataTxt);

    // file.writeAsString(_gameDataTxt, mode: FileMode.append);

    sink.close();
    return file;
  }
}

