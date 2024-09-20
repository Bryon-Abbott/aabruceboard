import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bruceboard/services/authservices.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:bruceboard/utils/banner_ad.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  const SignUp({super.key, required this.toggleView});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  bool _isHidden = true;

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

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
    return loading
      ? const Loading()
      : SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            title: const Text('Sign up to BruceBoard'),
            actions: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Sign In'),
                onPressed: () => widget.toggleView(),
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 50.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 5.0),
                          const Text("Email Address"),
                          TextFormField(
                            decoration: const InputDecoration(hintText: 'email@domain.com'),
                            validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("Password"),
                          TextFormField(
                            obscureText: _isHidden,
                            decoration: InputDecoration(
                              hintText: 'Password (6+ chars)',
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                    _isHidden
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined
                                ),
                              ),
//                      ),
                            ),
                           validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("Password Verification"),
                          TextFormField(
                            obscureText: _isHidden,
                            decoration: InputDecoration(
                              hintText: 'Password (6+ chars)',
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                    _isHidden
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined
                                ),
                              ),
//                      ),
                            ),
                            validator: (val) => val! != password ? 'Passwords entered are not the same' : null,
                            onChanged: (val) {
                              setState(() => passwordVerification = val);
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("First Name"),
                          TextFormField(
                            decoration: const InputDecoration(hintText: 'Enter First Name'),
                            validator: (val) => val!.trim().isEmpty ? 'Enter First Name' : null,
                            onChanged: (val) {
                              displayNameController.text = "${val.trim()} $lName";
                              initialsController.text =
                                  "${val.trim().isEmpty ? '.' : val.trim().substring(0, 1)}${lName.isEmpty ? '.' : lName.substring(0, 1)}";
                              setState(() => fName = val.trim());
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("Last Name"),
                          TextFormField(
                            decoration: const InputDecoration(hintText: 'Enter Last Name'),
                            validator: (val) => val!.trim().isEmpty ? 'Enter Last Name' : null,
                            onChanged: (val) {
                              displayNameController.text = "$fName ${val.trim()}";
                              initialsController.text =
                                  "${fName.trim().isEmpty ? '.' : fName.substring(0, 1)}${val.isEmpty ? '.' : val.trim().substring(0, 1)}";
                              setState(() => lName = val.trim());
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("Initials"),
                          TextFormField(
                            controller: initialsController,
                            decoration: const InputDecoration(hintText: 'Initials'),
                            validator: (val) => val!.trim().isEmpty ? 'Must enter initials ...' : null,
                            onChanged: (val) {
                              setState(() => initials = val.trim());
                            },
                          ),
                          const SizedBox(height: 5.0),
                          const Text("Display Name"),
                          TextFormField(
                            controller: displayNameController,
                            decoration: const InputDecoration(hintText: 'Display Name'),
                            //  validator: (val) => 'Enter Display Name' : null,
                            onChanged: (val) {
                              setState(() => displayName = val);
                            },
                          ),
                          const SizedBox(height: 5.0),
                          ElevatedButton(
                              style: const ButtonStyle(),
                              child: const Text( 'Sign Up' ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => loading = true);
                                  String rc = await registerUser(
                                    email: email.trim(), password: password,
                                    displayName:  displayName.isEmpty ? displayNameController.text : displayName,
                                    fName: fName, lName: lName,
                                    initials: initials.isEmpty ? initialsController.text : initials,
                                  );
                                  if (rc == "Success") {
                                    setState(() => Navigator.pop(context));
                                  } else {
                                    setState(() {
                                      loading = false;
                                      error = rc;
                                    });
                                  }
                                }
                              }
                            ),
                          const SizedBox(height: 5.0),
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
                const AdContainer(),
//                (kIsWeb) ? const SizedBox() : const AaBannerAd(),
              ],
            ),
          ),
        ),
      );
  }

// ==========================================================
  Future<String> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String fName, required String lName,
    required String initials,
  }) async {
    dynamic registerResults;
    String returnString = "Error: Unknown";

    log("Adding User: '$fName' '$lName' '$initials' '$displayName'", name: "${runtimeType.toString()}::registerUser()");
    try {
      registerResults = await _auth.registerWithEmailAndPassword(email, password, displayName,
          fName: fName, lName: lName, initials: initials);
      // FirebaseAuthExceptions have been limited so doesn't throw errors just returns null.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.', name: "${runtimeType.toString()}:registerUser()");
        returnString = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.', name: "${runtimeType.toString()}:registerUser()");
        returnString = 'The account already exists for that email.';
      }
    } catch (e) {
      log("Error Signing up: $e");
      returnString = 'Error Signing up: $e';
    }
    if (registerResults == null) {
      await openDialogError(email);
      returnString = 'Please supply a valid email and account info';
    } else {
      // Send Email verification.
      log("Adding User: '$fName' '$lName' '$initials' '$displayName'", name: "${runtimeType.toString()}:registerUser()");
      log("Resulting UID: ${registerResults.uid}");
      await openDialogNotification(email);
      _auth.signOut();
      returnString = "Success";
      // var rc = await registerResults.sendEmailVerification();
      // if (rc != null) {
      //   log("Sending Email Verification. ${rc}", name: "${runtimeType.toString()}:registerUser()");
      //   await openDialogNotification(email);
      //   returnString = "Success";
      // } else {
      //   await openDialogVerificationError(email);
      //   returnString = "Error: Failed to send verification email, please verify from the Profile page.";
      // }
    }
    return Future<String>.value(returnString);
  }

  Future<String?> openDialogNotification(String email) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Email Verification sent ... "),
          // titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          // contentTextStyle: Theme.of(context).textTheme.bodyLarge,
          content: Text(
              '''An email has been set to to your email address '$email'.
                 Please sign onto your email, verify your account 
                 then resign into your BruceBoard account'''
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );

  Future<String?> openDialogError(String email) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
          actionsPadding: const EdgeInsets.all(2),
          contentPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          title: const Text("Email Registration Failure ... "),
          titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          contentTextStyle: Theme.of(context).textTheme.bodyLarge,
          content: Text(
              '''Something went wrong with the registration for '$email'. 
                 Please try again with correct email.'''),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );

  Future<String?> openDialogVerificationError(String email) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
          actionsPadding: const EdgeInsets.all(2),
          contentPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          title: const Text("Email Verification Failure ... "),
          titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          contentTextStyle: Theme.of(context).textTheme.bodyLarge,
          content: Text(
              '''Something went wrong with the verification for '$email'.
                 Please try verifying again thru the Profile Page.''' ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
}
