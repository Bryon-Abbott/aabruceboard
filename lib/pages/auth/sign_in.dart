
import 'package:bruceboard/services/authservices.dart';
//import 'package:bruceboard/shared/constants.dart';
import 'package:bruceboard/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  const SignIn({super.key,  required this.toggleView });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Sign in to Bruce Board'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Sign Up'),
            onPressed: () => widget.toggleView(),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
//                decoration: textInputDecoration.copyWith(hintText: 'email'),
                decoration: const InputDecoration(hintText: 'email@doman.com'),
                //style: Theme.of(context).textTheme.titleMedium,
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(hintText: 'password (6+ chars)'),
//                decoration: textInputDecoration.copyWith(hintText: 'password'),
                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      //style: const ButtonStyle(),
                      child: const Text('Sign In'),
                      onPressed: () async {
                        if(_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                            User? result = await _auth.signInWithEmailAndPassword(
                                email, password);
                            if ( result == null ) {
                              setState(() {
                                loading = false;
                                error = 'Could not sign in with those credentials';
                              });
                            } else {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                        }
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      //style: const ButtonStyle(),
                        child: const Text('Reset Password'),
                        onPressed: () async {
                          if( email.isNotEmpty ) {
                            await _auth.sendPasswordResetEmail(email);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Password Reset Email sent to $email ... "))
                            );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Enter Email in Email field ... "))
                              );
                          }
                        }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(error),
            ],
          ),
        ),
      ),
    );
  }
}