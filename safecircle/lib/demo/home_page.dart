// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:safecircle/demo2/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_service.dart';

// // --------------------------------------------------------
// // HOME PAGE
// // --------------------------------------------------------
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FolderScreen();
//   }
// }

// // --------------------------------------------------------
// // FOLDER SCREEN
// // --------------------------------------------------------
// class FolderScreen extends StatefulWidget {
//   @override
//   State<FolderScreen> createState() => _FolderScreenState();
// }

// class _FolderScreenState extends State<FolderScreen> {
//   List folders = [];
//   bool isLoading = true;

//   final TextEditingController folderController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   // LOAD TOKEN & FOLDERS
//   Future<void> loadData() async {
//     final token = await ApiService.getToken();

//     if (token == null) {
//       _showMessage("Token missing. Please login again.");
//       setState(() => isLoading = false);
//       return;
//     }

//     await fetchFolders();
//   }

//   // FETCH USER FOLDERS (JWT)
//   Future<void> fetchFolders() async {
//     setState(() => isLoading = true);

//     final res = await FolderService.getUserFolders();

//     if (res["status"] == 200) {
//       folders = res["data"]["folders"];
//     } else {
//       _showMessage("Failed to load folders");
//     }

//     setState(() => isLoading = false);
//   }

//   // CREATE FOLDER (JWT)
//   Future<void> createFolder() async {
//     final name = folderController.text.trim();
//     if (name.isEmpty) {
//       _showMessage("Folder name required");
//       return;
//     }

//     final res = await FolderService.createFolder(name);

//     if (res["status"] == 200) {
//       folderController.clear();
//       fetchFolders();
//       _showMessage("Folder created");
//     } else {
//       _showMessage("Failed to create folder");
//     }
//   }

//   // OPEN CONTACT SCREEN
//   void openFolder(Map folder) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => ContactScreen(folder: folder)),
//     ).then((_) => fetchFolders());
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Folders")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: folderController,
//                           decoration: InputDecoration(
//                             hintText: "Folder name",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: createFolder,
//                         child: Text("Add"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: folders.isEmpty
//                       ? Center(child: Text("No folders found"))
//                       : ListView.builder(
//                           itemCount: folders.length,
//                           itemBuilder: (_, i) {
//                             final f = folders[i];
//                             return ListTile(
//                               leading: Icon(Icons.folder),
//                               title: Text(f['foldername']),
//                               onTap: () => openFolder(f),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

// // --------------------------------------------------------
// // CONTACT SCREEN
// // --------------------------------------------------------
// class ContactScreen extends StatefulWidget {
//   final Map folder;

//   ContactScreen({required this.folder});

//   @override
//   State<ContactScreen> createState() => _ContactScreenState();
// }

// class _ContactScreenState extends State<ContactScreen> {
//   List contacts = [];
//   bool isLoading = true;

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchContacts();
//   }

//   // GET CONTACTS INSIDE A FOLDER
//   Future<void> fetchContacts() async {
//     setState(() => isLoading = true);

//     final res = await FolderService.getFolderContacts(widget.folder['_id']);

//     if (res["status"] == 200) {
//       contacts = res["data"]["contacts"];
//     } else {
//       _showMessage("Failed to load contacts");
//     }

//     setState(() => isLoading = false);
//   }

//   // ADD CONTACT TO FOLDER (JWT)
//   Future<void> addContact() async {
//     final name = nameController.text.trim();
//     final phone = phoneController.text.trim();

//     if (name.isEmpty || phone.isEmpty) {
//       _showMessage("Fill all fields");
//       return;
//     }

//     final res = await FolderService.addContact(
//       widget.folder['_id'],
//       name,
//       phone,
//     );

//     if (res["status"] == 200) {
//       nameController.clear();
//       phoneController.clear();
//       fetchContacts();
//       _showMessage("Contact added");
//     } else {
//       _showMessage("Failed to add contact");
//     }
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Contacts in ${widget.folder['foldername']}")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: nameController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintText: "Name",
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         controller: phoneController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintText: "Phone",
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: addContact,
//                         child: Text("Add Contact"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: contacts.isEmpty
//                       ? Center(child: Text("No contacts found"))
//                       : ListView.builder(
//                           itemCount: contacts.length,
//                           itemBuilder: (_, i) {
//                             final c = contacts[i];
//                             return ListTile(
//                               leading: Icon(Icons.person),
//                               title: Text(c['c_name']),
//                               subtitle: Text(c['c_phone']),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
