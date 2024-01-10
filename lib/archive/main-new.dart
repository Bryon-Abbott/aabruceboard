import 'package:bruceboard/archive/wrapper.dart';
import 'package:bruceboard/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

// Brew Crew App - refactored to work. Bryon: 2023-10-15

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<BruceUser?>.value(
      initialData: BruceUser(
        uid: 'xx',
      ),
      value: AuthService().user,
      child: const MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}