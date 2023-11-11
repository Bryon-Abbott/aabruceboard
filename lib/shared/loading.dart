import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,  // .shadowColor, // .primaryColor,
      // color: Colors.brown[100],
      child: Center(
        child: SpinKitChasingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 50.0,
        ),
      ),
    );
  }
}