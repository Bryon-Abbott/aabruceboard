part of 'player_profile_page.dart';

abstract class PlayerProfileCtrl extends State<PlayerProfilePage> {

  final _formKey = GlobalKey<FormState>();

  // form values
  String? _currentFName;
  String? _currentLName;
  String? _currentInitials;
  String? _currentDisplayName;
  late Player player;
  BruceUser? bruceUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> updateOnPressed() async {
    if(_formKey.currentState!.validate()) {
      player.fName = (_currentFName != null) ? _currentFName!.trim() : player.fName;
      player.lName = (_currentLName != null) ? _currentLName!.trim() : player.lName;
      player.initials = (_currentInitials != null) ? _currentInitials!.trim() : player.initials;
      //player.pid = player.pid;
      log("player_profile: Update Player '${player.fName}' '${player.lName}'");
      await DatabaseService(FSDocType.player, uid: bruceUser?.uid).fsDocUpdate(player);
      await AuthService().updateDisplayName(
        _currentDisplayName ?? AuthService().displayName
      );
      setState(() {
        Navigator.pop(context);
      } );
    }
  }
  // Todo: Look at moving the messaging to the Auth Services to reduce duplication in sign_up page.
  void verifyOnPressed() {
    log("Pressed verify", name: "${runtimeType.toString()}:verifyOnPressed()");
    if (bruceUser != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Email Verification sent ... '),
            content: Text(
                '''An email has been set to to your email address '${bruceUser!.email}'. 
                   Please sign onto your email, verify your account 
                   then resign into your BruceBoard account'''),
            actions: [
              ElevatedButton(
                child: const Text('Ok'),
                onPressed:() {
                  log("Pressed Ok", name: "${runtimeType.toString()}:verifyOnPressed()");
                  bruceUser!.sendEmailVerification();
                  bruceUser!.signOut();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
      );
      log("Sending Email", name: "${runtimeType.toString()}:verifyOnPressed()");
    }
  }

  Future<void> deleteOnPressed() async {
    log("Pressed delete", name: "${runtimeType.toString()}:deleteOnPressed()");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete your Account?'),
          content: const Text(
              '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.

Since this is a security-sensitive operation, you eventually are asked to login before your account can be deleted.'''),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red)
              ),
              onPressed:() {
                log("Pressed second RED delete", name: "${runtimeType.toString()}:deleteOnPressed()");
                bool rc = bruceUser!.deleteUserAccount();
                if (rc) { // If deleted, set Player status to Disabled
                  log("Account Deleted ...", name: "${runtimeType.toString()}:deleteOnPressed()");
                  player.status = 0;
                  DatabaseService(FSDocType.player, uid: bruceUser?.uid).fsDocUpdate(player);
                  log("Player Update to Disabled ...", name: "${runtimeType.toString()}:deleteOnPressed()");
                } else {
                  // if (!context.mounted) return;
                  log("Account NOT  Deleted ...", name: "${runtimeType.toString()}:deleteOnPressed()");
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("This operation is sensitive and requires recent authentication. Log in again before retrying this request..."))
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}