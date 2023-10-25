import 'dart:developer';
import 'package:bruceboard/models/board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/models/game.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/services/database.dart';
import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key, required this.game});
  final Game game;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // final _formKey = GlobalKey<FormState>();
  late String _sid;
  late String _gid;
  late String _pid;
  late Game game;

  @override
  void initState() {
    game = widget.game;
    _sid = game.sid;
    _gid = game.gid;
    _pid = game.pid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    BruceUser bruceUser = Provider.of<BruceUser>(context);
    _sid = game.sid;

    return StreamBuilder<Board>(
        stream: DatabaseService(pid: _pid, sid: _sid, gid: _gid ).board,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            Board board = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Bruce Board'),
                centerTitle: true,
                elevation: 0,
              ),
              body: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text('Game Board',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  Text('Game Name: ${game.name}'),
                  Text('Board Splits: '
                      '${board.percentSplits[0]}, ${board.percentSplits[1]}, '
                      '${board.percentSplits[2]}, ${board.percentSplits[3]}, '
                      '${board.percentSplits[4]}'
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      // style: ButtonStyle(
                      //   backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[400]!),
                      // ),
                        child: Text('Update',),
//                        style: TextStyle(color: Colors.white),
//                      ),
                        onPressed: ()  {},
                    ),
                  ),
                ],
              ),
            );
          } else {
            log("game_test: Error ${snapshot.error}");
            return Loading();
          }
        }
    );
  }
}