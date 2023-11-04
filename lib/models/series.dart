import 'dart:developer';

import 'package:bruceboard/services/database.dart';

class Series  {
  final String sid;  // Numeric S0000-S9999
  String name;
  String type;
  int noGames=0;

  Series({ required this.sid, required this.name, required this.type, required this.noGames });
}