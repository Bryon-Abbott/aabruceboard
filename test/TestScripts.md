# Test scripts 
This is a document with test scripts

## User / Player Test 

## Community / Membership Tests

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