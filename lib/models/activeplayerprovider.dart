import 'package:bruceboard/models/player.dart';
// ToDo: Refactor ActivePlayerProvider and CommunityPlayerProvider into 1 provider.
// class SeriesPlayer with ChangeNotifier {
class ActivePlayerProvider {
  // Player _player = Player(data: {});
  Player activePlayer = Player(data: {});

  // set activePlayer(Player player) {
  //   _player = player;
  //   // notifyListeners();
  // }
  //
  // Player get activePlayer => _player;
}