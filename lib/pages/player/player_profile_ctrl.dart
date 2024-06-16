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
      player.fName = _currentFName ?? player.fName;
      player.lName = _currentLName ?? player.lName;
      player.initials = _currentInitials ?? player.initials;
      player.pid = player.pid;
      // log("player_profile: Update Player ${player.fName}");
      await DatabaseService(FSDocType.player, uid: bruceUser?.uid).fsDocUpdate(player);
      await AuthService().updateDisplayName(
        _currentDisplayName ?? AuthService().displayName
      );
      setState(() {
        Navigator.pop(context);
      } );
    }
  }

  Future<void> verifyOnPressed() async {
    log("Pressed verify");
  }
}