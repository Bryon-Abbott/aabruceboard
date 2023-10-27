class Community {
  final String cid;
  final String pid;
  final String name;
  String approvalType="AUTO";
  int noMembers=0;

  Community({ required this.cid, required this.pid, required this.name, required this.approvalType, required this.noMembers  });

}