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
