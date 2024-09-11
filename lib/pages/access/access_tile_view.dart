import 'package:bruceboard/pages/series/series_list_view.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/access.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/player.dart';

class AccessTileView extends StatelessWidget {
  final Player communityOwner;
  final Community community;
  final Access access;
  const AccessTileView({super.key,
    required this.communityOwner,
    required this.community,
    required this.access
  });

  @override
  Widget build(BuildContext context) {
    return SeriesListView(
      access: access,
      communityOwner: communityOwner,
      community: community);
  }
}