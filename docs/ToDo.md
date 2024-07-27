


## Change to Multi App
We need to create an "Amdin" App and potentially a "Pro" App

### Look at structure 
Sample Structure 
```
my_flutter_project/
|-- apps/
|   |-- mobile_app/
|   |   |-- lib/
|   |   |-- android/
|   |   |-- ios/
|   |   |-- pubspec.yaml
|   |
|   |-- web_app/
|   |   |-- lib/
|   |   |-- web/
|   |   |-- pubspec.yaml
|   |
|   |-- dev_app/
|       |-- lib/
|       |-- pubspec.yaml
|
|-- lib/
|   |-- models/
|   |-- services/
|   |-- utils/
|   |-- widgets/
|   |-- main.dart
|
|-- pubspec.yaml
|-- README.md
|-- .gitignore
```
### Package
Create Database Package
## Bugs
+ Fix Game Names on Score Prompt
+ Fix Update Profile, update Home Page
+ -------
+ Fill remaining squares active when board is full - Fixed
+ Score active after distribution - Fixed
+ Distribution didn't send message to Owner? - Fixed (Assign Remining not filling in community)
## General Updates 
+ Create FAQ
+ Update Documentation
+ Add Documentation to AbbottAvenue
+ Update AbbottAvenue - Business site
+ 
## Build Host Auto Approve
## Add Limits for Free Version 
What Limits are required?
+ Player Limit number of Active Games with Selected Squares?
+ Owner Limit number of Active Series (2) (easy)
+ Owner Limit number of Active Games in Series being Run (2) (easy)
+ Owner Limit number of Communities (1) (easy)
+ Player Limit number of Communities in - Memberships (1) (easy)
+ Player Limit number of Squares Active
+ 