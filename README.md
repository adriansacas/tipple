# CS371L Tipple


## Alpha Doc

## Contributions

Adrian Sanchez (25%)
-
- Settings storyboard
  - Update profile info view controllers to update name, dob, gender, height, weight, phone, email, profile picture
- FirestoreManager class to manage create, update, and delete Firestore database operations
- ProfileInfo class to manage profile operations
- Fire Storage Setup
- AlertUtils class

Andrew White (25%)
-
- Session/Drink Info Classes
  - Wrote classes for a given session and different types of drinks
  - Jointly defined data schema for Firebase storage of sessions
  - Wrote & added FirestoreManager methods to create/retrieve/update sessions & drinks for a session
- ActiveSessions storyboard
  - Created views for inital questionnare for a session 
  - Created session locally/firebase & displays information for session
    - Updates firebase session as changes are made within view
    - Keeps track of users drinks / runningBAC / and a status and updates view as changes are inputed

Claudia Castillo (25%)
-
- All of Previous Sessions list view, Day view, and Symptoms updater
- Minor changes to SessionInfo and DrinkInfo
- Some contribution in designing the data schema to tailor to what my screens needed

Danica Padlan (25%)
-
- Initial Firebase setup
- All of Login, Registration, and Home page
- Checked and saved user's email, password, and personal data to Firebase
- Connect some segues from Home page to other storyboards



## Differences/Deviations
- Password and Confirm Password text field in Register page has a 
'Cannot show Automatic Strong Passwords' error when setting isSecureTextEntry to true, will work on finding the solution to this by Beta
- In order for a user to update their email address they must re-authenticate and confirm their email first. However, can't seem to be able to send emails. Will investigate further. 
- Previous sessions not presented as a calendar but rather a list view due to experiencing issues going from a selected date to the Day View
- Symptoms not yet saved to a session in firebase as it would require to change many current working areas
- Total drinks in Day View presented by a simple counter rather than a pie chart, will look into changing for beta
- Notifications pushed to beta, still deciding the best approach to them
- Drink increments are presented through an alert instead of a hidden/unhidden stepper. Experiencing issues on displaying stepper at appropriate time/place
- No way to go to settings/previous sessions/friends list from a current running session. Will implement in beta.


