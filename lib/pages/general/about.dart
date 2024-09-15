import 'dart:developer';

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
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text("BruceBoard",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text("A Sports Pool App",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                          text: "General Description: ",
                          style: Theme.of(context).textTheme.titleMedium,
                          children: <TextSpan>[
                            TextSpan(text: 'This is an application to allow Friends and Organizations to ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextSpan(text: 'manage standard 10x10 Sports pools, managing credits, ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextSpan(text: 'entering scores and displaying overall results.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
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
                          style: Theme.of(context).textTheme.titleMedium,
                          children: <TextSpan> [
                            TextSpan(text: "Add Players, Add Games, Assign Players to Squares ",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextSpan(text: "Enter quarterly scores and display player points ",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ]
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                            text: "Additional Documentation: ",
                            style: Theme.of(context).textTheme.titleMedium,
                            children: <TextSpan> [
                              TextSpan(text: "Documentation on how to use BruceBoard ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextSpan(text: "can be viewed by clicking the documentation ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextSpan(text: "icon in the top right of the About Page.",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ]
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                            text: "Application Status: ",
                            style: Theme.of(context).textTheme.titleMedium,
                            children: <TextSpan> [
                              TextSpan(text: "This application is currently in early development ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextSpan(text: "and Accounts, Games and Communities may ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextSpan(text: "deleted periodically. ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              TextSpan(text: "Please provide any feedback to the Technical Manager. ",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ]
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    // const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(text: "Product Manager: ",
                          style: Theme.of(context).textTheme.titleMedium,
                          children: [
                            TextSpan(text:  "Meagan Sheehan",
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          ]
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(text: "Technical Manager: ",
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(text:  "Bryon Abbott, \n      Bryon.Abbott@abbottavenue.com",
                                style: Theme.of(context).textTheme.bodyLarge,
                              )
                            ]
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0,),
                    Text("Version: ${_packageInfo.version} (${_packageInfo.buildNumber})",
                        textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ]
                ),
              ),
            ),
            (kIsWeb) ? const SizedBox() : const AaBannerAd(),
          ],
        )
      ),
    );
  }
}