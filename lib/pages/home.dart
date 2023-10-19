import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:bruceboard/utils/brucearguments.dart';
import 'package:bruceboard/utils/players.dart';
import 'package:bruceboard/utils/games.dart';
import 'package:bruceboard/pages/settings_main.dart';
import 'package:bruceboard/theme/thememanager.dart';
// ==========
// Desc: Load home screen
// ----------
// 2023/09/12 Bryon   Created
// ==========
class Home extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final VoidCallback onChanged;

  const Home({
    super.key,
    this.savedThemeMode,
    required this.onChanged,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Map data = {};
  //Object? parameters;
  late BruceArguments args;
  late Players players;
  late Games games;
//  bool settingDarkMode = false;

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
    args = ModalRoute.of(context)!.settings.arguments as BruceArguments;
    players = args.players;
    games = args.games;

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
        title: Text('Home'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
//              color: Colors.blue,
              onSelected: (item) => onMenuSelected(context, item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Settings"),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.white),
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
                SizedBox(height: 80,),
                Text('Welcome ',
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
                    SizedBox(
                      height: 300,
                      width: 150,
                      child: Image(
                        image: AssetImage('assets/AdobeStock_55757786-vert.jpeg'),
                      ),
                    ),
                    Column(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            Navigator.pushNamed(
                                context, '/manageplayers', arguments: BruceArguments(players, games));
                          },
                          icon: Icon(
                            Icons.person,
                            size: 32,
                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                          ),
                          label: Text('Players',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            Navigator.pushNamed(
                                context, '/managegames', arguments: BruceArguments(players, games));
                          },
                          icon: Icon(
                            Icons.sports_football_outlined,
                            size: 32,
                            color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.red,
                          ),
                          label: Text('Games',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton.icon(
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
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 50.0),
                Text(
                  "... Enjoy ...",
                  // data['time'],
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ]),
          ),
        ),
      ),
    );
  }
}
// Helper Functions
void onMenuSelected(BuildContext context, int item) {
  switch (item) {
    case 0:
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsMain()),
      );
      if (kDebugMode) {
        print("Item Selected $item");
      }
      break;
    case 1:
      if (kDebugMode) {
        print("Item Selected $item - Exit");
      }
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      break;
  }
}