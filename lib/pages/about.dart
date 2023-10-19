import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ==========
// Desc: Create About() class and associated about info.
// ----------
// 2023/07/20 Bryon   Created
// ==========
class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        backgroundColor: Colors.grey,
        appBar: AppBar(
//          backgroundColor: Colors.blue[900],
          title: const Text('About'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Container(
                  child: Text("Bruce Board is a standard Football Pool board",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                      TextSpan(
                        children: const <TextSpan>[
                          TextSpan(text: 'This is a game application to allow friends to '),
                          TextSpan(text: 'manage a Football pool, collecting points, '),
                          TextSpan(text: 'entering scores and displaying point results.'),
                        ],
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(
                    TextSpan(
                        text: "Key Features include: ",
                        children: const <TextSpan> [
                          TextSpan(text: "Add Players, Add Games, Assign Players to Squares "),
                          TextSpan(text: "Enter quarterly scores and display player points "),
                        ]
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                SizedBox(height: 40),
                Text("Product Manager: Meagan Sheehan",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text("For technical items contact Bryon.Abbott@abbottavenue.com",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                Text("App Name: ${_packageInfo.appName}",
                    textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text("Version: ${_packageInfo.version}",
                    textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text("Release: ${_packageInfo.buildNumber}",
                    textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ]
          ),
        )
    );
  }
}

