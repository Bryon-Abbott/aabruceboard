import 'dart:developer';

import 'package:bruceboard/models/activeplayerprovider.dart';
import 'package:bruceboard/models/community.dart';
import 'package:bruceboard/models/communityplayerprovider.dart';
import 'package:bruceboard/models/firestoredoc.dart';
import 'package:bruceboard/models/member.dart';
import 'package:bruceboard/models/membership.dart';
import 'package:bruceboard/models/membershipprovider.dart';
import 'package:bruceboard/models/player.dart';
import 'package:bruceboard/pages/access/access_list_series.dart';
import 'package:bruceboard/pages/access/access_list_view.dart';
import 'package:bruceboard/pages/series/series_list_view.dart';
import 'package:bruceboard/services/databaseservice.dart';
import 'package:bruceboard/services/messageservice.dart';
import 'package:bruceboard/shared/helperwidgets.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MembershipTileCascade extends StatelessWidget {
  final Membership membership;
  final Player communityOwner;
  final Community community;
  final Member member;
  MembershipTileCascade({super.key,
    required this.membership,
    required this.communityOwner,
    required this.community,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<MembershipProvider>(context).currentMembership = membership;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.red[800]!
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Community: ${community.name} (${communityOwner.fName} ${communityOwner.lName}) "),
              Text("Membership: ${membership.key}  Credits: ${member.credits}"),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: 324,
                  minWidth: double.infinity,
                ),
                child: AccessListView(
                  communityOwner: communityOwner,
                  community: community,
                ),
              ),
          ],
                ),
        ),
      ),
    );
  }
}