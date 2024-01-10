
import 'package:bruceboard/models/player.dart';
import 'package:flutter/foundation.dart';

// class SeriesPlayer with ChangeNotifier {
class CommunityPlayerProvider {
  Player _player = Player(data: {});

  void set communityPlayer(Player player) {
    _player = player;
    // notifyListeners();
  }

  Player get communityPlayer => _player;
}