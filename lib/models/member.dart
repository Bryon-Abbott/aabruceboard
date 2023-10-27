class Member {
  final String cid;
  final String pid;  // /Player/{PID}/Community/{CID}/Member/{PID} Note: PID = MID
  int credits=0;

  Member({ required this.cid, required this.pid, required this.credits, });

}