
import 'package:bruceboard/models/player.dart';

// class SeriesPlayer with ChangeNotifier {
// class CommunityPlayerProvider {
//   Player _player = Player(data: {});
//
//   set communityPlayer(Player player) {
//     _player = player;
//     // notifyListeners();
//   }
//
//   Player get communityPlayer => _player;
// }
class CommunityPlayerProvider {
  Player communityPlayer = Player(data: {});
}