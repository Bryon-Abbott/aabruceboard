// ==========
// Desc: Create Settings() class to store and manage settings
// ----------
// 2023/09/12 Bryon   Created
// ==========
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:bruceboard/utils/preferences.dart';
import 'package:bruceboard/utils/icon_widget.dart';

class SettingsScoring extends StatefulWidget {
  const SettingsScoring({super.key});

  @override
  State<SettingsScoring> createState() => _SettingsScoringState();
}

class _SettingsScoringState extends State<SettingsScoring> {
  // static const keyBreakIn = 'key-breakin';
  // static const keyWinningScore = 'key-winningscore';
  // static const keyThreeOnes = 'key-threeones';
  String settingThreeOnes = "";
  String settingBreakIn = "";
  String newBreakIn = "";
  bool updateBreakInDisable = true;

  @override
  void initState() {
    super.initState();
    // print("Init State");
    // settingThreeOnes = "111";
    // settingBreakIn = "222";
    // newBreakIn = settingBreakIn;
    // updateBreakInDisable = true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Scoring Settings'),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              Preferences.removePreferences(Preferences.keyUndefinedString);
              Navigator.pop(context);
            });
          },
          icon: const Icon(Icons.clear_all),
          tooltip: "Clear Settings and return ...",
        ),
      ],
    ),
    body: SafeArea(
      child: SettingsList(
        contentPadding: const EdgeInsets.all(24),
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
              title: const Text('General'),
              tiles: [
                SettingsTile(
                  title: const Text("Winning Round Score"),
                  leading: const Icon(Icons.scoreboard),
                  trailing: const IntegerFormField(
                    sharedPreferenceKey: Preferences.keyWinningScore,
                    initialValue: '10000',
                  ),
                ),
                SettingsTile(
                  title: const Text("Break In Score"),
                  leading: const Icon(Icons.scoreboard),
                  trailing: const IntegerFormField(
                    sharedPreferenceKey: Preferences.keyBreakInScore,
                    initialValue: '500',
                  ),
                ),
              ]
          ),
          SettingsSection(
            title: const Text("Roll Scores"),
            tiles: [
              SettingsTile(
                title: const Text("Three Ones"),
                leading: const Icon(Icons.scoreboard),
                trailing: const IntegerFormField(
                  sharedPreferenceKey: Preferences.keyThreeOnesScore,
                  initialValue: '300',
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

