import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Series Model class', () {
    Map<String, dynamic> data =
    { 'sid': -1,
      'name': 'Test Series',
      'type': 'None',
      'noGames': 0,
    };
    Series series = Series(data: data);

    test('sid should start at -1', () {
      expect(series.sid, -1);
    });

    test('noGames should start at 0', () {
      expect(series.noGames, 5);
    });

  });

  group('Test Community Model class', () {
    Map<String, dynamic> data =
    { 'cid': -1,
      'uid': 'UIDXXXYYY',
      'name': 'Community Name',
      'type': 'Community TYpe',
      'noMembers': 0,
    };
    Community community = Community(data: data);

    test('sid should start at -1', () {
      expect(community.cid, -1);
    });

    test('noGames should start at 0', () {
      expect(community.noMembers, 0);
    });

  });

}