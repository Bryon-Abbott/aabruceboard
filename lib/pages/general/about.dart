import 'dart:developer';

import 'package:bruceboard/utils/adhelper.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void>? _launched;
  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

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

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Uri bruceBoardManual =
    Uri(scheme: 'https', host: 'www.abbottavenue.com', path: 'bruceboard-doc/UserManual.html');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          actions: [
            IconButton(
              onPressed: () {
                log("Pressed Menu", name: "${runtimeType.toString()}:AppBar-Action");
                  _launched = _launchInBrowser(bruceBoardManual);
              },
              icon: const Icon(Icons.book_outlined),
              tooltip: "Clear ALL Settings and return ...",
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text("Bruce Board is a standard Football Pool board",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  const TextSpan(
                    children: <TextSpan>[
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
                  const TextSpan(
                    text: "Key Features include: ",
                    children: <TextSpan> [
                      TextSpan(text: "Add Players, Add Games, Assign Players to Squares "),
                      TextSpan(text: "Enter quarterly scores and display player points "),
                    ]
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 40),
              Text("Product Manager: Meagan Sheehan",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text("Technical Manager: Bryon Abbott, Bryon.Abbott@abbottavenue.com",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0,),
//              const Spacer(),
//                // Text("User Manual: https://www.abbottavenue.com/bruceboard/docs/index.html",
              //   textAlign: TextAlign.start,
              //   style: Theme.of(context).textTheme.titleSmall,                ),
              // Text("App Name: ${_packageInfo.appName}",
              //     textAlign: TextAlign.start,
              //   style: Theme.of(context).textTheme.titleSmall,
              // ),
              Text("Version: ${_packageInfo.version} (${_packageInfo.buildNumber})",
                  textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8.0,),
              (!kIsWeb)
                  ? const SizedBox()
                  : const AaBannerAd(),
              // Text("Release: ${_packageInfo.buildNumber}",
              //     textAlign: TextAlign.start,
              //   style: Theme.of(context).textTheme.titleSmall,
              // ),
            ]
          ),
        )
      ),
    );
  }
}