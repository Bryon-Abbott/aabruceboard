import 'dart:developer';

import 'package:bruceboard/services/authservices.dart';
// import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {

  final Function toggleView;
  const SignUp({super.key,  required this.toggleView });

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String passwordVerification = '';
  String displayName = '';
  String fName = '';
  String lName = '';
  String initials = '';
  late TextEditingController displayNameController;
  late TextEditingController initialsController;

  @override
  void initState() {
    super.initState();
    displayNameController = TextEditingController();
    initialsController = TextEditingController();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    initialsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
//      backgroundColor: Colors.brown[100],
      appBar: AppBar(
//        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: const Text('Sign up to Bruce Board'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Sign In'),
            onPressed: () => widget.toggleView(),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  const Text("Email Address"),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'email@domain.com'),
//                    decoration: textInputDecoration.copyWith(hintText: 'email'),
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("Password"),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'password'),
//                    decoration: textInputDecoration.copyWith(hintText: 'password'),
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("Password Verification"),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'reenter password'),
//                    decoration: textInputDecoration.copyWith(hintText: 'reenter password'),
                    obscureText: true,
                    validator: (val) => val! != password ? 'Passwords entered are not the same' : null,
                    onChanged: (val) {
                      setState(() => passwordVerification = val);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("First Name"),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter First Name'),
//                    decoration: textInputDecoration.copyWith(hintText: 'First Name'),
                    validator: (val) => val!.trim().isEmpty ? 'Enter First Name' : null,
                    onChanged: (val) {
                      displayNameController.text = "${val.trim()} $lName";
                      initialsController.text = "${val.trim().isEmpty ? '.' : val.trim().substring(0,1)}${lName.isEmpty ? '.' : lName.substring(0,1)}";
                      setState(() => fName = val.trim());
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("Last Name"),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Enter Last Name'),
//                    decoration: textInputDecoration.copyWith(hintText: 'Last Name'),
                    validator: (val) => val!.trim().isEmpty ? 'Enter Last Name' : null,
                    onChanged: (val) {
                      displayNameController.text = "$fName ${val.trim()}";
                      initialsController.text = "${fName.trim().isEmpty ? '.' : fName.substring(0,1)}${val.isEmpty ? '.' : val.trim().substring(0,1)}";
                      setState(() => lName = val.trim());
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("Initials"),
                  TextFormField(
                    controller: initialsController,
                    decoration: const InputDecoration(hintText: 'Initials'),
//                    decoration: textInputDecoration.copyWith(hintText: 'Initials'),
                    validator: (val) => val!.trim().isEmpty ? 'Must enter initials ...' : null,
                    onChanged: (val) {
                      setState(() => initials = val.trim());
                    },
                  ),
                  const SizedBox(height: 10.0),
                  const Text("Display Name"),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(hintText: 'Display Name'),
//                    decoration: textInputDecoration.copyWith(hintText: 'Display Name'),
                    //  validator: (val) => 'Enter Display Name' : null,
                    onChanged: (val) {
                      setState(() => displayName = val);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: const ButtonStyle(
                    ),
                    child: const Text('Sign Up', ),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        setState(() => loading = true);
                        log("Adding User: F'$fName' L'$lName' I'$initials' D'$displayName'", name: "${runtimeType.toString()}:buildScore");
                        dynamic result = await _auth.registerWithEmailAndPassword(email, password,
                            displayName.isEmpty ? displayNameController.text : displayName,
                            fName: fName, lName: lName,
                            initials: initials.isEmpty ? initialsController.text : initials);
                        if(result == null) {
                          setState(() {
                            loading = false;
                            error = 'Please supply a valid email';
                          });
                        } else {
                          setState(() => Navigator.pop(context));
                        }
                      }
                    }
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    error,
                    style: TextStyle(
                    //                    color: Colors.red,
                        color: Theme.of(context).highlightColor,
                        fontSize: 14.0),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}