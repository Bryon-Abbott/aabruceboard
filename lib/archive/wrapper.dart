import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/auth/authenticate.dart';
import 'package:bruceboard/pages/general/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final bruceUser = Provider.of<BruceUser?>(context);
    //final player = Provider.of<Player>(context);
    
    // return either the Home or Authenticate widget
    if (bruceUser == null){
      return const Authenticate();
    } else {
      return const Home();
    }
    
  }
}