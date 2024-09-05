import 'package:flutter/cupertino.dart';

class SignInMessage extends StatelessWidget {
  const SignInMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        ''' 
Welcome Message 

Sign In to see games
  Click the +Person Icon to sign in
  Create and Account from the Sign In Page, Click the Sign Up button in the top right.  

"My Community" Tab shows games you have access to through your community memberships. 

"Public Games" Tab shows games the owner has made open to the public 
  Select a public game to request access to the Community

Additional Documentation can be accessed from the About page by pressing the Document icon in the top right. 

Enjoy         
        '''
      ),
    );
  }
}
