import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(home: HomePage()));
}

// ---------------- Home Page ----------------
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FolderScreen();
  }
}

// ---------------- Folder Screen ----------------
class FolderScreen extends StatefulWidget {
  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List folders = [];
  String? token, userID;
  bool isLoading = false;
  final folderController = TextEditingController();
  final String baseUrl = "https://wsa-1.onrender.com/api/folder";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    userID = prefs.getString("userID");

    print("DEBUG → TOKEN: $token");
    print("DEBUG → USER ID: $userID");

    if (token != null && userID != null) {
      _fetchFolders();
    } else {
      print("DEBUG → USER NOT LOGGED IN");
    }
  }

  Future<void> _fetchFolders() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/all"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          folders =
              data['folders']?.where((f) => f['userID'] == userID).toList() ??
              [];
        });
      } else {
        _showMessage("Error fetching folders");
      }
    } catch (e) {
      _showMessage("Network error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createFolder() async {
    final name = folderController.text.trim();
    if (name.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "foldername": name,
          "userID": userID, // ✅ REQUIRED
        }),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        folderController.clear();
        _fetchFolders(); // refresh list
        _showMessage("Folder created");
      } else {
        _showMessage(data['message'] ?? "Create failed");
      }
    } catch (e) {
      _showMessage("Network error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _openFolder(folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactScreen(folder: folder, token: token!),
      ),
    ).then((_) => _fetchFolders());
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folders")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: folderController,
                    decoration: const InputDecoration(
                      hintText: "Folder name",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createFolder(),
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
                : ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (_, index) {
                      final folder = folders[index];
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder['foldername'] ?? "Unnamed"),
                        onTap: () => _openFolder(folder),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Contact Screen ----------------
class ContactScreen extends StatefulWidget {
  final Map folder;
  final String token;
  const ContactScreen({required this.folder, required this.token});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List contacts = [];
  bool isLoading = false;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final String baseUrl = "https://wsa-1.onrender.com/api/contact";

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/${widget.folder['_id']}"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => contacts = data['contacts'] ?? []);
      } else {
        _showMessage("Error fetching contacts");
      }
    } catch (e) {
      _showMessage("Network error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addContact() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode({
          "folderID": widget.folder['_id'],
          "c_name": name,
          "c_phone": phone,
        }),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        nameController.clear();
        phoneController.clear();
        _fetchContacts();
        _showMessage("Contact added");
      } else {
        _showMessage(data['message'] ?? "Add failed");
      }
    } catch (e) {
      _showMessage("Network error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts in ${widget.folder['foldername']}")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Name",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Phone",
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? const Center(child: Text("No contacts found"))
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (_, i) {
                      final c = contacts[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c['c_name'] ?? ""),
                        subtitle: Text(c['c_phone'] ?? ""),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
