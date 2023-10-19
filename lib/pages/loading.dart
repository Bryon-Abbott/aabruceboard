import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:bruceboard/utils/players.dart';
import 'package:bruceboard/utils/games.dart';
import 'package:bruceboard/utils/brucearguments.dart';
// ==========
// Desc: Create Players() class and load users from persistence data.
// Display splash screen while waiting.
// ----------
// 2023/07/20 Bryon   Created
// ==========
class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void setupPlayers() async {
    Players players = Players(); // Initialize Players Singleton
    Games games = Games(); // Initialize Games Singleton

    await players.loadPlayers();
    await games.loadGames();

    // Pause a bit to see the splash screen :)
    //await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      if (kDebugMode) {
        print('Something went wrong ... ');
      }
      return;
    }
    Navigator.pushReplacementNamed(context, '/home', arguments: BruceArguments(players, games));
  }

  @override
  void initState() {
    super.initState();
    setupPlayers();
  }

  @override
  Widget build(BuildContext context) {


    return const Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SpinKitFadingCube(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}

