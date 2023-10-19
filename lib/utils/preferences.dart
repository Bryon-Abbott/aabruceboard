//
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences preferences;

//  static const keyDarkMode = 'key-darkmode';
  static const keyPlayers = 'key-players';
  static const keyGameAxisScore = 'key-gameaxisscore';  // Not used game key is a function of gameNo.
  static const keyGameBoardData = 'key-gameboarddata';  // Not used game key is a function of gameNo.
  static const keyPlayerNextNo = 'key-playernextno';
  static const keyExcludePlayerNo = 'key-excludeplayerno';
  static const keyGameNextNo = 'key-gamenextno';

  // Todo: remove these when Settings is cleaned up.
  static const keyWinningScore = 'key-winningscore';
  static const keyThreeOnesScore = 'key-threeonesscore';
  static const keyBreakInScore = 'key-breakinscore';

  static const keyUndefinedString = 'key-undefinedstring';
  static const keyALL = 'key-ALL';


  static Future init() async =>
      preferences = await SharedPreferences.getInstance();

  // // Dark Mode
  // static Future setDarkMode(bool mode) async =>
  //     await preferences.setBool(keyDarkMode, mode);
  //
  // static bool getDarkMode() =>
  //     preferences.getBool(keyDarkMode) ?? false;

  static Future setPlayerNextNo(int playerNo) async =>
      await preferences.setInt(keyPlayerNextNo, playerNo);

  static int getPlayerNextNo() =>
      preferences.getInt(keyPlayerNextNo) ?? 1001;

  static Future setGameNextNo(int gameNo) async =>
      await preferences.setInt(keyGameNextNo, gameNo);

  static int getGameNextNo() =>
      preferences.getInt(keyGameNextNo) ?? 1001;

  static Future setPreferenceString(String key, String value) async {
    //print("Saving Pref $key value $value");
    await preferences.setString(key, value);
  }

  static String? getPreferenceString(String key) {
    return preferences.getString(key);
  }

  static Future removePreferences(String key) async {

    switch(key) {
      case keyUndefinedString : {
        debugPrint('Clear Default preference data');
        // Todo: remove these when Settings is cleaned up.
        await preferences.remove(keyWinningScore);
        await preferences.remove(keyBreakInScore);
        await preferences.remove(keyThreeOnesScore);
        break;
      }
      case keyALL : {
        debugPrint('Clear ALL preference data');
        await preferences.clear();
        break;
      }
      default: {
        debugPrint('Clear preference data for $key');
        await preferences.remove(key);
        break;
      }
    }
  }
}