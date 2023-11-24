import 'dart:developer';
import 'package:bruceboard/models/messageowner.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/models/message.dart';
//import 'package:bruceboard/pages/message/message_maintain.dart';

class MessageTile extends StatelessWidget {

  final Message message;
  const MessageTile({ super.key,  required this.message });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          onTap: () {
            log("Message Tapped ... ${message.docId} ");
          },
          leading: const Icon(Icons.message_outlined),
          title: Text('Message: ${message.docId} Type: ${message.type}'),
          subtitle: Text('Comment: ${message.userMessage} '),
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