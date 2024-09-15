import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/models/series.dart';
import 'package:bruceboard/pages/game/game_list_view.dart';
import 'package:flutter/material.dart';

class SeriesTileView extends StatelessWidget {
  final Series series;
  final Player seriesOwner;
  final Membership membership;

  const SeriesTileView({ super.key,
    required this.seriesOwner,
    required this.series,
    required this.membership,
  });

  @override
  Widget build(BuildContext context) {
    return GameListView(
      membership: membership,
      seriesOwner: seriesOwner,
      series: series);
  }
}