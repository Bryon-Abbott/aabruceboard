import 'dart:developer';
import 'package:bruceboard/models/messageowner.dart';
import 'package:flutter/material.dart';

//import 'package:bruceboard/pages/message/message_maintain.dart';

class MessageOwnerTile extends StatelessWidget {

  final MessageOwner messageOwner;
  const MessageOwnerTile({ super.key,  required this.messageOwner });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            log("Message Tapped ... ${messageOwner.docId} ");
          },
          leading: const Icon(Icons.message_outlined),
          title: Text('Message: ${messageOwner.docId} Name: ??? '),
          subtitle: Text('Uid: ${messageOwner.uid} '),
          trailing: IconButton(
              onPressed: (){
                log('Pressed edit icon');
              },
              icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}