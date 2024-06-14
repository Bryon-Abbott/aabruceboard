
import 'package:bruceboard/services/auth.dart';
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
              ElevatedButton(
                  style: const ButtonStyle(
//                    backgroundColor: MaterialStateProperty.all<Color>(Colors.pink[400]!),
                  ),
                child: const Text(
                  'Sign In',
//                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    // try {
                    //   User? result = await _auth.signInWithEmailAndPassword(
                    //       email, password)
                    //       .then((currentUser) {
                    //     log('Signon Successful');
                    //     Navigator.pop(context);
                    //   })
                    //       .catchError((error) {
                    //     log('Signon Faild');
                    //     setState(() {
                    //       loading = false;
                    //       error = error.code;
                    //     });
                    //   });
                    // } catch (e) {
                    //   log('Error caught');
                    // }
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
// Note: The catch code below is never executed???
//                     } on FirebaseAuthException catch (e) {
//                       log('Signin Firebase Auth Error');
//                         setState(() {
//                           loading = false;
//                           error = e.code;
//                         });
//                       // if (e.code == 'weak-password') {
//                       //   print('The password provided is too weak.');
//                       // } else if (e.code == 'email-already-in-use') {
//                       //   print('The account already exists for that email.');
//                       // }
//                     } catch (e) {
//                       log('Signin Other Error');
//                       setState(() {
//                           loading = false;
//                           error = e.toString();
//                         });
//                     }
                  }
                }
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
//                style: TextStyle(color: Theme.of(context).highlightColor, fontSize: Theme.of(context)...),
              ),
            ],
          ),
        ),
      ),
    );
  }
}