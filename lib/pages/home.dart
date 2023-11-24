
import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bruceboard/pages/player/player_profile.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:bruceboard/pages/settings_main.dart';
import 'package:bruceboard/theme/theme_manager.dart';

// ==========
// Desc: Load home screen
// ----------
// 2023/09/12 Bryon   Created
// ==========
class Home extends StatefulWidget {
  const Home({super.key});


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    themeManager.addListener(themeListener);
    //Preferences.setDarkMode(true);
    // bool settingDarkMode = Preferences.getDarkMode() ?? false;
    super.initState();
  }

  themeListener(){
    if(mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final bruceUser = Provider.of<BruceUser?>(context) ?? BruceUser(uid: 'x');
    //final DatabaseService _db = DatabaseService(uid: bruceUser.uid);

    // Calculate screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newScreenHeight = screenHeight - padding.top - padding.bottom;
    double newScreenWidth = screenWidth - padding.left - padding.right;
    //dev.log("Screen Dimensions are Height: $screenHeight, Width: $screenWidth : Height: $newScreenHeight, Width: $newScreenWidth", name: " ${this.runtimeType.toString()}:build");

      return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
            color: Colors.white.withOpacity(0)
          ) ,
          onPressed: null,
        ),
        title: const Text('Home'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
//              color: Colors.blue,
              onSelected: (item) => onMenuSelected(context, item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined),
                      SizedBox(width: 8),
                      Text("Sign Out"),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline),
                      SizedBox(width: 8),
                      Text("Profile"),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 8),
                      Text("Settings"),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<int>(
                    value: 3,
                    child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text("Exit"),
                        ]
                    )
                ),
              ]
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          height: newScreenHeight,
          width: newScreenWidth,
          color: Theme.of(context).colorScheme.background,
          child: SingleChildScrollView(
            child: Column(
                  children: <Widget>[
                const SizedBox(height: 80,),
                Text('Welcome',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text('Bruce Squares Board',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text('Football Pool App',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 300,
                        width: 150,
                        child: Image(
                          image: AssetImage('assets/AdobeStock_55757786-vert.jpeg'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid == 'x') ? null : () async {
                                Navigator.pushNamed(context, '/community-list');
                              },
                              icon: Icon(
                                Icons.person,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Communities',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid == 'x') ? null : () async {
                                Community? community;
                                Player? player;
                                dynamic results = await Navigator.pushNamed(context, '/community-select');
                                if (results != null) {
                                  player = results[0] as Player;
                                  community = results[1] as Community;
                                  log("Join Community: ${community.name} ${player.pidKey} ${community.key}");
                                }
                              },
                              icon: Icon(
                                Icons.person,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Join Community',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid == 'x') ? null : () async {
                                Navigator.pushNamed(context, '/membership-list');
                              },
                              icon: Icon(
                                Icons.collections_outlined,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Memberships',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid == 'x') ? null : () async {
                                Navigator.pushNamed(
                                  //  context, '/manageplayers', arguments: BruceArguments(players, games));
                                context, '/series-list');
                              },
                              icon: Icon(
                                Icons.sports_football_outlined,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Series',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid == 'x') ? null : () async {
                                Navigator.pushNamed(
                                    context, '/message-list');
                              },
                              icon: Icon(
                                Icons.message_outlined,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Messages', style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: (bruceUser.uid != 'x') ? null : () async {
                                Navigator.pushNamed(
                                  //  context, '/managegames', arguments: BruceArguments(players, games));
                                context, '/authenticate');
                              },
                              icon: Icon(
                                Icons.login,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('Sign In',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/about');
                              },
                              icon: Icon(
                                Icons.question_mark,
                                size: 32,
                                color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                              ),
                              label: Text('About',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 50.0),
                Text(
                  "... Enjoy ...",
                  // data['time'],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
               // Spacer(),
                const SizedBox(height: 50.0),
                Text("Welcome '${bruceUser==null ? "????" : bruceUser.displayName}'",
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
              ]),
          ),
        ),
      ),
    );
  }
}
// Helper Functions
void onMenuSelected(BuildContext context, int item) async {
  final AuthService auth = AuthService();
  switch (item) {
    case 0:
      await auth.signOut();
      break;
    case 1:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PlayerProfile()),
      );
      break;
    case 2:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsMain()),
      );
      break;
    case 3:
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      break;
  }
}