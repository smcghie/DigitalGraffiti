# Digital Graffiti
An AR artwork social media application to share artwork and AR art galleries, built with SwiftUI, UIKit, MapKit, Core Location, Firebase and ARKit.

<br>

### Augmented Reality Preview and Gallery Feature

<img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/47e2e3a4-2a87-4b36-8f6d-3ca19fdeba06" width=25%>

- Preview artwork in augmented reality using ARKit
- Save WorldMap and anchor points to cloud firestore allowing users to share and edit galleries from separate devices
- Resizable and reconfigurable
- Images adapt to ambient light for more realistic appearance
  
<br>
<br clear="right"/>
<br>

---

### AR Gallery Locations Stored on User's Profile using MapKit

<img align="left" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/98089eb6-f203-4c55-b7ab-88764d98de6d" width=25%>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * View AR gallery location on map relative to user's position <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Details of location shows WorldMap location for user to find exact gallery location <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Users can then load WorldMap to view gallery from this screen
  
<br>
<br clear="left"/>
<br>

---

### Firebase Authorization and User Database

  <img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/0e8c7f03-d904-4fa2-9330-25a1f8d30901" width=25%>

- Users can create and edit profiles 
- Authentication by Firebase
- Profiles stored in Firestore

<br>
<br clear="right"/>
<br>

---

### Users Can Change Avatar and Update Username

<img align="left" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/7ace601c-ab05-4786-aa59-1049db19cfcc" width=25%>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Settings page allows users to choose new avatar and resize it <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Users can also update username
  
<br>
<br clear="left"/>
<br>

---

### Wall

  <img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/4aa6f212-f359-4077-800a-712f86feea63" width=25%>

- Artwork displayed in scrollable view
- Menus and navigation disappear on scroll
- Tab bar returns to main view on tap, not child views

<br>
<br clear="right"/>
<br>

---

### Chats
  <img align="left" src ="https://github.com/smcghie/DigitalGraffiti/assets/26985349/459d2f01-c403-4b10-8a4a-874e0955fda2" width=25%>

  - User chat system with Firebase backend
  - Users can share artwork and galleries

<br>
<br clear="left"/>
<br>

---

### Chat Screen
  <img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/9fb6dd48-f019-461b-a3a4-660845e68995" width=25%>

  - All chats listen for updates and redirect to latest message
  - Shared artworks appear as thumbnail preview in chat window
  
<br>
<br clear="right"/>
<br>

---

### Image Details

  <img align="left" src ="https://github.com/smcghie/DigitalGraffiti/assets/26985349/b1c9285e-aabf-46dd-81ce-547b3b38013f" width=25%>

  - Taping artwork from wall redirects to details page
  - displays name, description
  - header provides ability to redirect to artist profile, share the art, message the artist, or preview in AR

  
<br>
<br clear="left"/>
<br>

---

### Profile
  <img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/d9009a43-cbce-47bf-86e1-8e389b08c644" width=25%>

  - Allows users to view artist profile, their followers and who they're following
  - Allows users to follow artist
  - Users can go to the artist's AR gallery to display, manipulate, save and restore their artworks in AR
  - If the current users is the artist, gives the ability to travel to upload screen to add to their gallery
    
<br>
<br clear="right"/>
<br>

---

### Upload
  <img align="left" src ="https://github.com/smcghie/DigitalGraffiti/assets/26985349/e2561d7e-181c-445e-af08-47c57ab3766f" width=25%>

  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Users can upload images and include name and description <br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * Users can delete posts
  
<br>
<br clear="left"/>
<br>

---

### Followers
  <img align="right" src="https://github.com/smcghie/DigitalGraffiti/assets/26985349/90074a4f-5008-4841-ab62-5676b6393f47" width=25%>

  - Application supports followers
  - Users can see who follows them and who they're following
  - Allows sharing of artwork between followers
  
<br>
<br clear="right"/>
<br>

---

### Resize
  <img align="left" src ="https://github.com/smcghie/DigitalGraffiti/assets/26985349/32c961cf-192e-4a16-b659-27e7722fa20b" width=25%>

  - Custom image cropped to allow users to adjust avatars to desired size
  - Compresses cropped images and uploads them to firestore
  
<br>
<br clear="left"/>
<br>

---

### Zoom
  <img align="right" src ="https://github.com/smcghie/DigitalGraffiti/assets/26985349/7a155bda-31e6-474e-822b-c2ff8ceeb383" width=25%>

  - From artwork details users can fullscreen the artwork for more detail
  - Users can zoom, un-zoom, and drag the image around the screen
  - Supports detection of orientation change to allow horizontal viewing of art
<br>
<br clear="left"/>
<br>


