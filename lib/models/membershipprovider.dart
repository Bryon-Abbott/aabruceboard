

// class SeriesPlayer with ChangeNotifier {
import 'package:bruceboard/models/membership.dart';

class MembershipProvider {
  Membership _membership = Membership(data: {});

  set currentMembership(Membership membership) {
    _membership = membership;
    // notifyListeners();
  }

  Membership get currentMembership => _membership;
}