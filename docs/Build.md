# Bruce Board Build Setup
## Add Firestore 
(Firestore Configure)[https://firebase.google.com/docs/flutter/setup?platform=ioskhttps://firebase.google.com/docs/flutter/setup?platform=ios]


## Firebase Structrue 
Messages Process
Sender has "Create" access to /Player/{UID-Receiver}/Message/{UID-Sender}/Incoming/{Send-Msg-ID}
Sender writes message to : 
/Player/{UID-Receiver}/Message/{UID-Sender}/Incoming/{Send-Msg-ID}
Receiver reads message and processes it, copy to Processed and deleting from Request
/Player/{UID-Receiver}/Message/{UID-Sender}/Processed/{Send-Msg-ID}
Receiver send Response back to Sender
/Player/{UID-Sender}/Message/{UID-Receiver}/Response/{Send-Msg-ID}

Message Class: 
MSID = Message ID, Unique to Sender
Type = {Community Join Request-M001, Square Select Request-M002}


MessageClass 
Sender UID = Me
Receiver UID = Recever
