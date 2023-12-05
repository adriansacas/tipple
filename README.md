# CS371L Tipple

**Group number**: 5

**Team members**: Adrian Sanchez Castaneda, Claudia Castillo, Danica Padlan, Andrew White

**Dependencies**: Xcode 15.0, Swift 5.3

**Special Instructions**:
- **Group Sessions --> Joining A Session**
    - Group Sessions are joinable through a QR Code. This requires the application to be pushed onto an iOS device with a camera in order to scan QR code
    - **!!! For the sake of this submission and TA testing !!!** We have added a UIAlert that lets the TA enter the session ID. Additionally, the sessionID is presented as a UILabel only if running on simulator.
- **Running the app**
    - xxx
    - xxx
    - xxx

## Feature Table
| Feature | Description | Release Planned | Release Actual | Deviations | Who/Percentage Worked On |
| :---:   |    :---:    |      :---:      |      :---:     |   :---:    |           :---:          |
| Login and Sign Up | Allows the user to create and sign into their account   | Alpha   | Alpha   | X   | Danica (100%)   |
| Face ID Login | Allows the user to login with Face ID   | Alpha   | Final   | X   | Danica (100%)   |
| Home Page | Connects user to other features of the app   | Alpha   | Alpha   | X   | Danica (100%)   |
|Settings | User can update their account information and set privacy and appearance settings   | Alpha   | Alpha   | X   | Adrian (100%)   |
| QR Scanner | Users can join a group session by scanning a QR code through the built-in camera   | Beta   | Beta   | X   | Andrew (90%), Claudia (5%, provided initial code), Danica (5%, generated QR code)   |
| Personal Drink Counter | Users can track their own number of drinks and BAC   |  Alpha  | Alpha   | Replaced increment with UI alert rather than part of the view controller. Also removed idea for sidebar and pushed these features to different locations | Andrew (90%), Danica (10%, drew cup statuses)    |
| Warning Notifications | Designated Driver, Underaged Drinker, Other's BAC, Slow Down/Stop   | Alpha   | Final   | Switched to alerts instead of originally planned push notifications   | Claudia(90%), Danica (10%, added 'Underaged Drinker' alert)   |
| Previous Sessions | Can view a list of all your previously logged sessions with detailed breakdown of each one with drink logs   | Alpha   | Alpha   | Initially planned to be displayed as a calendar but kept as a list for simplicity   | Claudia (80%), Andrew (20%, Firebase storage and methods)  |
| Symptoms Tracker and Morning-After Tips | Can log symptoms after a session is finished through the previous sessions logs and receive tips based on what is logged   | Alpha   | Beta   | X   | Claudia (80%, UI), Andrew (20%, Firebase storage and methods)   |
| Group Sessions | User can start a group session to track members of their group and post polls   | Alpha   | Alpha   | X   | Danica (75%), Andrew (25%, syncing information to Firebase)   |
| Members List | Displays everyone in a group session. Can individually view each person's detailed info (BAC, location, active status)   | Beta   | Beta   | X   | Claudia (80%, UI), Andrew (20%, Firebase storage and methods)   |
| Tracking Locations | Tracks a person's last known location. Can be seen by other's in their group session if enabled.   | Stretch Goal   | Final   | X   | Claudia (10%, UI), Andrew (90% handled concurrent location updates w/ firebase)   |
| Group Polls | Create and delete polls in group sessions. Allow multiple voting. Allow participants to add options. See polls results.  | Beta   | Final   | X   | Adrian   |
| UI | Colors, buttons, and user navigation flow   | Final   | Final   | X   | Adrian (25%), Claudia (25%), Danica (25%), Andrew (25%)   |


##Beta Notes (delete for Final Submission)
Adrian Sanchez (25%)
-
- Firebase
    - Created schema for polls
    - Added methods to handle get / update / create / delete polls
    - Logic to keep parity between groupSessions and polls references
- Polls
    - View controllers to view list of polls created in the session, create polls, vote in a poll, and see the results of a poll
    - Custom prototype cell classes
    - Inline add options to polls
    - Swipe delete polls
- UI
    - Global navigation bar appearance
    - Hex to UIColor tool

Andrew White (25%)
-
- Firebase
    - Redid schema for concurrent sessions between multiple users
    - Jointly ensured symptoms were being stored in Firebase for a given user
    - Wrote many methods for creating and updating fields within Firebase
- QR Scanner
    - Connected view controllers to pass in read in fields from QR Code
    - Ensured to prompt user for camera access and set fields in plist.
- Sessions
    - Restructured view controllers to be repurposed no matter kind of session (indiv/group)
    - Used UI made by Danica for group sessions and connected them with my ActiveSession/Questions pages
    - Wrote methods to poll firebase for most up to date information for joint members of a group session (opposed to someone who created it)
    - Wrote polling methods for memberslist and relevant fields for tableview displaying
    - Used Danica's alerts to mark sessions as deleted on Firebase
    - Made alerts to disallow users to join a session they've previously left

Claudia Castillo (25%)
-
- Helped ensure symptoms are stored in Firebase and updated properly in the previous session view
- Generated tips based on logged symptoms when looking at a previous session
- Added a pie chart to view drinks taken in a previous session
- Created a view controller and implemented code for scanning a QR code to join a session
- Created view controllers and implemented code to display list of members in a group and detailed information for each user
- Created alerts during individual sessions for when a user should slow down/stop drinking based on BAC
- Improved previous session's UI to match app theme

Danica Padlan (25%)
-
- Fixed Password and Confirm Password text field in Register page to hide text
- Handled basic functionality and UI for Group Session VCs (Register/Manage/Edit Group Session VC and Invite Code VC)
- Created and triggered alerts and segues for when a Group session will be end or be deleted
- Registered and updated session name labels and end time and date in the Manage/Edit Group Sessions and Invite Code VCs
- Made sure the submitted session name was under a character limit and end time and date could not be set to anytime before the current time
- Generated unique QR codes based on the sessionID String for group sessions
- Cleaned up UI for Login, Registration, and Home VCs
- Updated Group Session VCs UI to match Figma design
- Helped Andrew with passing values from Questionnaire VC to Manage Sessions VC



## Differences/Deviations
- Currently cannot test if the QRScanner works with the Camera because XCode currently doesn't support iOS 17.1 (only goes up to 17.0 as of now) and crashes the app on Danica's phone.
- Registeration VC only dismisses the keyboard by pressing 'Return' key, touching in scroll view is currently not working. Will fix in Final Submission.
- Signing out of an account is a buggy since it always assumes the user will be signed in even after clicking the sign out button. Will fix in Final submission.
- Originally planned notifications were turned into alerts due to having to pay for ADP, however, they still serve the same functionality
    - Alerts to check on another user in a group session are still being worked on
- Previous sessions will no longer be displayed as a calendar and stay as a tableview
- Poll expiration, allow multiple votes and change vote implementation moved to final release
