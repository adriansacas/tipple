# CS371L Tipple

## Group number: 5

## Team members: Adrian Sanchez Castaneda, Claudia Castillo, Danica Padlan, Andrew White

## Dependencies: Xcode 10.2, Swift 4
## Special Instructions:
-
- Running the app
    - x
    - x
    - x

## Testing README table
| Feature | Description | Release Planned | Release Actual | Deviations | Who/Percentage Worked On |
| :---:   |    :---:    |      :---:      |      :---:     |   :---:    |           :---:          |
| X | X   | X   | X   | X   | X   |

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
