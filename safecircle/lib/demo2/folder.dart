import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:safecircle/demo2/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<dynamic> folders = [];
  bool isLoading = true;

  final TextEditingController folderController = TextEditingController();

  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------------- LOAD USER ID ----------------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");

    print("Loaded User ID: $userID");

    if (userID == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("UserID missing. Please login again.")),
      );
      return;
    }

    _fetchFolders();
  }

  // ---------------------- FETCH USER FOLDERS ----------------------
  Future<void> _fetchFolders() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService2.getFolders(userID!);

      print("Folders API Response: $res");

      final List data = res["folders"] ?? [];

      setState(() {
        folders = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching folders: $e")));
    }
  }

  // ---------------------- CREATE FOLDER WITH USER ID ----------------------
  Future<void> _createFolder() async {
    final name = folderController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter folder name")));
      return;
    }

    if (userID == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID missing")));
      return;
    }

    try {
      final res = await ApiService2.addFolder(
        folderName: name,
        userID: userID!,
      );

      print("Create Folder Response: $res");

      if (res["success"] == true) {
        folderController.clear();
        _fetchFolders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create folder")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // ---------------------- OPEN FOLDER ----------------------
  void _openFolder(Map folder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactScreen(folder: folder)),
    ).then((_) => _fetchFolders());
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Folders")),
      body: Column(
        children: [
          // ----------- Add Folder -----------
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

          // ----------- Folder List -----------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : folders.isEmpty
                ? const Center(child: Text("No folders found"))
                : ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final f = folders[index];

                      // Normalize response
                      final folder = {
                        "id": f["_id"] ?? f["id"],
                        "folderName":
                            f["folderName"] ?? f["foldername"] ?? "Unnamed",
                      };

                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder["folderName"]),
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
