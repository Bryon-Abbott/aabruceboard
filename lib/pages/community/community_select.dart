import 'dart:developer';

import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/utils/banner_ad.dart';
import 'package:flutter/material.dart';

class CommunitySelect extends StatefulWidget {
  const CommunitySelect({super.key});

  @override
  State<CommunitySelect> createState() => _CommunitySelectState();
}

class _CommunitySelectState extends State<CommunitySelect> {
  //Map<String, dynamic> data =;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FirestoreDoc>>(
        stream: DatabaseService(FSDocType.community).fsDocListStream,
        builder: (context, snapshots) {
          if (snapshots.hasData) {
            List<Community> community = snapshots.data!.map((s) => s as Community).toList();
            return Scaffold(
              appBar: AppBar(
                title: const Text('Select Community'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0)),
                  // if user presses back, cancels changes to list (order/deletes)
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: community.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(community[index].name),
                          subtitle: Text("Community: ${community[index].key}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () {
                              log('Icon Pressed', name: '${runtimeType.toString()}:ListTile:onPressed()');
                              Navigator.of(context).pop(community[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const AdContainer(),
//                  (kIsWeb) ? const SizedBox() : const AaBannerAd(),
                ],
              ),
            );
          } else {
            log("community_list: Snapshot Error ${snapshots.error}");
            return const Loading();
          }
        });
  }
}
