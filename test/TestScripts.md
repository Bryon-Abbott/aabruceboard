# Test scripts 
This is a document with test scripts
## Index
- 01.User 
  	- 01.01.Register Player
  	- 01.02.Update Profile
	- 01.03.Remvoe Player
- 02.Community 
	- 02.01.Add Community
	- 02.02.Edit Community
	- 02.03.Delete Community
- 03.Series
	- 03.01.Add Series
	- 03.02.Edit Series 
	- 03.03.Delete Sereis
	- 04.10.Assign Community 
	- 04.11.Remove Community 
- 04.Games
	- 04.01.Add Game
	- 04.02.Edit Game 
	- 04.03.Delete Game
- 05.Memberships
	- 05.01.Request Add to Community
		- 05.01.01.Accept Community Add Request (See Messages)
		- 05.01.02.Reject Community Add Request (See Messages)
	- 05.02.Request Remove from Community 
		- 05.02.01.Accept Community Remove Request (See Messages)
		- 05.02.02.Reject Community Remvoe Request (See Messages)
	- 05.03.Request Membership Add Credits
		- 05.03.01.Accept Membership Add Credit Request (See Messages)
		- 05.03.02.Reject Community Add Credit Request (See Messages)
	- 05.04.Request Membership Add Credits
		- 05.04.01.Accept Membership Add Credit Request (See Messages)
		- 05.04.02.Reject Community Add Credit Request (See Messages)
- 06.Boards
	- 06.01.View Board
	- 06.02.Set Scores 
	- 06.03.Request Square 
- 07.Messages 
	- 07.01.Accept Community Add Request
	- 07.02.Reject Community Add Request
	- 07.03.Accept Community Add/Remove Response
	- 07.04.Accept Community Remove Request
	- 07.05.Reject Community Remvoe Request
	- 07.06.Accept Community Add/Remove Response
	- 07.07.Accept Membership Add Credits Request
	- 07.08.Reject Membership Add Credits Request
	- 07.09.Accept Membership Add Response
	- 07.07.Accept Membership Remove Credits Request
	- 07.08.Reject Membership Remove Credits Request
	- 07.09.Accept Membership Remove Response

## 01.User / Player Test 

## 02.Community / Membership Tests

1. User2, Add Community 
   - Results 
      - Adds Community, members is 0
1. User2, Edit Community
   - Results 
     - Community Names changed
1. User1, In Memberships, Request to be added to Community 
   - Results: 
      - Adds Memberships, "Requested"
      - Send message to Owner
1. User2, In Messages, Accept Request
    - Results 
      - Message Archived
      - Message sent to Requester (Accepted) 
1. User1: Accept Response 
   - Results: 
     - Check Membership, Status=Requested 
     - In Messages, accept message,
     - Message Archived
     - Check Membership Message Archived
1. User2, Check Community Members 
   - Results 
     - Member count increased (+1)
     - Member added
1. Done 