# CS371L Tipple



## Alpha Doc

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Contributions

Adrian Sanchez (%)
-
- Settings storyboard
  - Update profile info view controllers to update name, dob, gender, height, weight, phone, email, profile picture
- FirestoreManager class to manage create, update, and delete Firestore database operations
- ProfileInfo class to manage profile operations
- Fire Storage Setup
- AlertUtils class

Andrew White (%)
-
- 
-
-

Claudia Castillo (%)
-
- All of Previous Sessions list view, Day view, and Symptoms updater
- Minor changes to SessionInfo and DrinkInfo
- Some contribution in designing the data schema to tailor to what my screens needed

Danica Padlan (%)
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

