import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/player_list.dart';
import 'package:bruceboard/pages/player_tile.dart';
//import 'package:bruceboard/screens/home/brew_list.dart';
import 'package:bruceboard/pages/player/profile.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    void _showSettingsPanel() {
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: SettingsForm(),
        );
      });
    }

    aaUser user = Provider.of<aaUser>(context);

    return StreamProvider<List<Player>>.value(
      initialData: [],
      value: DatabaseService(uid: user.uid).players,
      child: Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          title: Text('Player'),
//          backgroundColor: Colors.green[400],
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.settings),
              label: Text('settings'),
              onPressed: () => _showSettingsPanel(),
            )
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/AdobeStock_55757786-vert.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: PlayerList(),
        ),
      ),
    );
  }
}