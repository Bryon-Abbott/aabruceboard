//import 'package:bruceboard/theme/theme_manager.dart';
import 'package:flutter/material.dart';

const COLOR_PRIMARY = Colors.deepOrangeAccent;
const COLOR_ACCENT = Colors.orange;
//const BODY_COLOR = Colors.black;
Color BODY_COLOR = Colors.green[900] ?? Colors.green;
Color BODY_COLOR_DARK = Colors.green[300] ?? Colors.green;
//Color BODY_COLOR = Colors.lime[900] ?? Colors.lightGreen;

// ===========================================================================
// LIGHT Theme
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  //primaryColor: COLOR_PRIMARY,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
    background: Colors.green[100],
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR,
    ),
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR,
    ),
    bodyMedium: TextStyle(
      color: BODY_COLOR,
    ),
    headlineMedium: TextStyle(
      color: BODY_COLOR,
    )
  ),

  appBarTheme: const AppBarTheme(
    color: Colors.green,
    toolbarHeight: 40,
    titleTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    )
  ),

  floatingActionButtonTheme:
    FloatingActionButtonThemeData(backgroundColor: COLOR_ACCENT),

  elevatedButtonTheme: ElevatedButtonThemeData(
     style: ButtonStyle(
       textStyle: MaterialStateProperty.all(
          const TextStyle(
//              fontSize: 10,
              fontWeight: FontWeight.normal
// //              fontWeight: FontWeight.w100
           )
       ),
      // side: MaterialStateProperty.all(
      //   BorderSide(
      //     color: Colors.black,
      //   )
      // ),
      alignment: Alignment.center,
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(2)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
         // side: const BorderSide(color: Colors.lightGreenAccent),
        ),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide.none),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.1)
  )
);

// ===========================================================================
// DARK Theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,

  brightness: Brightness.dark,
  // accentColor: Colors.white,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.brown,
    brightness: Brightness.dark,
    background: Colors.green[900]
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR_DARK,
    ),
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR_DARK,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: BODY_COLOR_DARK,
    ),
    bodyMedium: TextStyle(
      color: BODY_COLOR_DARK,
    ),
      headlineMedium: TextStyle(
        color: BODY_COLOR_DARK,
      )
  ),

  appBarTheme: const AppBarTheme(
      color: Colors.green,
      toolbarHeight: 40,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      )
  ),


  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all<Color>(Colors.grey),
    thumbColor: MaterialStateProperty.all<Color>(Colors.white),
  ),

  inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.1)),


  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all(
        const TextStyle(
//          fontSize: 20,
          fontWeight: FontWeight.normal
        )
      ),
      alignment: Alignment.center,
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(1)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
//          side: const BorderSide(color: Colors.lightGreenAccent),
        ),
      ),
    ),
  ),

  // elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ButtonStyle(
  //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
  //             EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
  //         shape: MaterialStateProperty.all<OutlinedBorder>(
  //             RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0))),
  //         backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
  //         foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
  //         overlayColor: MaterialStateProperty.all<Color>(Colors.black26))),
);

// theme: ThemeData(
//   // Define the default brightness and colors.
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: Colors.green,
//     // ···
//     brightness: Brightness.light,
//   ),
//
//   appBarTheme: const AppBarTheme(
//     toolbarHeight: 40,
//     titleTextStyle: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       color: Colors.white,
//     ),
//     iconTheme: IconThemeData(
//       color: Colors.white,
//     )
//   ),
////

// ),


// colorScheme: ColorScheme(
//   background: Colors.green[900] ?? Colors.green,
//   brightness: Brightness.dark,
//   primary: Colors.green[900] ?? Colors.green,
//   error: Colors.red,
//   onError: Colors.red,
//   onBackground: Colors.green,
//   onPrimary: Colors.green,
//   onSecondary: Colors.white,
//   onSurface: Colors.white,
//   secondary: Colors.white,
//   surface: Colors.white,
// ),

