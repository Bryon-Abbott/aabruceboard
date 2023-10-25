import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/auth/authenticate.dart';
import 'package:bruceboard/pages/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final bruceUser = Provider.of<BruceUser?>(context);
    //final player = Provider.of<Player>(context);
    
    // return either the Home or Authenticate widget
    if (bruceUser == null){
      return Authenticate();
    } else {
      return Home();
    }
    
  }
}