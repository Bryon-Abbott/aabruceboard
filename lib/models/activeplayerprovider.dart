
import 'package:bruceboard/models/player.dart';
import 'package:flutter/foundation.dart';

// class SeriesPlayer with ChangeNotifier {
class ActivePlayerProvider {
  Player _player = Player(data: {});

  void set activePlayer(Player player) {
    _player = player;
    // notifyListeners();
  }

  Player get activePlayer => _player;
}