import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folders & Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FolderScreen(),
    );
  }
}

// ------------------ Folder Screen ------------------
class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<dynamic> folders = [];
  final TextEditingController folderController = TextEditingController();
  final String baseUrl = "https://wsa-1.onrender.com/api/folder";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("$baseUrl/all"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          folders = data['folders'] ?? [];
        });
      } else {
        debugPrint("Error fetching folders: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
//create folder have some problem 
  Future<void> _createFolder() async {
    final folderName = folderController.text.trim();
    if (folderName.isEmpty) {
      debugPrint("Folder name is empty");
      return;
    }

    try {
      debugPrint("Creating folder: $folderName");

      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"folderName": folderName}),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          debugPrint("Folder created successfully");
          folderController.clear();
          _fetchFolders();
        } else {
          debugPrint(
            "Error creating folder: ${data['message'] ?? 'Unknown error'}",
          );
        }
      } else {
        debugPrint("HTTP error while creating folder: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
    }
  }

  void _openFolder(Map folder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactScreen(folder: folder)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folders")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: folderController,
                    decoration: const InputDecoration(
                      hintText: "Enter folder name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createFolder,
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : folders.isEmpty
                ? const Center(child: Text("No folders found"))
                : RefreshIndicator(
                    onRefresh: _fetchFolders,
                    child: ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        return ListTile(
                          title: Text(folder['name'] ?? "Unnamed"),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => _openFolder(folder),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ------------------ Contact Screen ------------------
class ContactScreen extends StatefulWidget {
  final Map folder;

  const ContactScreen({super.key, required this.folder});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> contacts = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final String baseUrl = "https://wsa-1.onrender.com/api/contact";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      isLoading = true;
    });
    final folderID = widget.folder['_id'];
    try {
      final response = await http.get(Uri.parse("$baseUrl/$folderID"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          contacts = data['contacts'] ?? [];
        });
      } else {
        debugPrint("Error fetching contacts: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addContact() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
    final folderID = widget.folder['_id'];
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "folderID": folderID,
          "c_name": nameController.text,
          "c_phone": phoneController.text,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          nameController.clear();
          phoneController.clear();
          _fetchContacts();
        } else {
          debugPrint("Error adding contact: ${data['message']}");
        }
      } else {
        debugPrint("Error adding contact: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts in ${widget.folder['name']}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Contact Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    hintText: "Contact Phone",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text("Add Contact"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? const Center(child: Text("No contacts found"))
                : RefreshIndicator(
                    onRefresh: _fetchContacts,
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(contact['c_name'] ?? ""),
                          subtitle: Text(contact['c_phone'] ?? ""),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
