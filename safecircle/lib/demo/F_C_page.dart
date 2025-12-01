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
  final String baseUrl =
      "https://wsa-1.onrender.com/api/folder"; // update if needed
  bool isLoading = false;

  // Selection mode state
  bool selectionMode = false;
  final Set<String> selectedItems = {};

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
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching folders')));
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final foldername = folderController.text.trim();
    if (foldername.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Folder name is empty')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"foldername": foldername}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          folderController.clear();
          _fetchFolders();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Folder created')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Create folder failed')),
          );
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error while creating folder')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    }
  }

  void _openFolder(Map folder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactScreen(folder: folder)),
    ).then((_) => _fetchFolders());
  }

  void _onItemLongPress(String id) {
    setState(() {
      selectionMode = true;
      selectedItems.add(id);
    });
  }

  void _onItemTap(String id, Map folder) {
    if (selectionMode) {
      setState(() {
        if (selectedItems.contains(id)) {
          selectedItems.remove(id);
          if (selectedItems.isEmpty) selectionMode = false;
        } else {
          selectedItems.add(id);
        }
      });
    } else {
      _openFolder(folder);
    }
  }

  Future<void> _confirmAndDeleteSelected() async {
    if (selectedItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected folders?'),
        content: Text(
          'Delete ${selectedItems.length} folder(s) and their contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _deleteSelectedFolders();
  }

  Future<void> _deleteSelectedFolders() async {
    final url = Uri.parse("$baseUrl/delete");
    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": selectedItems.toList()}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Folders deleted')));
          setState(() {
            selectionMode = false;
            selectedItems.clear();
          });
          _fetchFolders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Delete failed')),
          );
        }
      } else {
        debugPrint('Delete error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error while deleting')),
        );
      }
    } catch (e) {
      debugPrint('HTTP error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    }
  }

  void _clearSelection() {
    setState(() {
      selectionMode = false;
      selectedItems.clear();
    });
  }

  void _selectAllItems() {
    setState(() {
      selectionMode = true;
      selectedItems.clear();
      for (var f in folders) {
        selectedItems.add(f['_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text('${selectedItems.length} selected')
            : const Text('Folders'),
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAllItems,
                  tooltip: 'Select all',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmAndDeleteSelected,
                ),
              ]
            : [],
      ),
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
                      hintText: 'Enter folder name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createFolder(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createFolder,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : folders.isEmpty
                ? const Center(child: Text('No folders found'))
                : RefreshIndicator(
                    onRefresh: _fetchFolders,
                    child: ListView.builder(
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        final foldername = folder['foldername'];
                        final isSelected = selectedItems.contains(foldername);

                        return ListTile(
                          leading: selectionMode
                              ? Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                )
                              : const Icon(Icons.folder),
                          title: Text(foldername ?? 'Unnamed'),
                          trailing: !selectionMode
                              ? const Icon(Icons.arrow_forward)
                              : null,
                          tileColor: isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                          onTap: () => _onItemTap(foldername, folder),
                          onLongPress: () => _onItemLongPress(foldername),
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
  final String baseUrl =
      "https://wsa-1.onrender.com/api/contact"; // update if needed
  bool isLoading = false;

  // Selection state
  bool selectionMode = false;
  final Set<String> selectedItems = {};

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching contacts')),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addContact() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name or phone is empty')));
      return;
    }

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Contact added')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Add failed')),
          );
        }
      } else {
        debugPrint('Error adding contact: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error while adding contact')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    }
  }

  void _onItemLongPress(String id) {
    setState(() {
      selectionMode = true;
      selectedItems.add(id);
    });
  }

  void _onItemTap(String id) {
    if (selectionMode) {
      setState(() {
        if (selectedItems.contains(id)) {
          selectedItems.remove(id);
          if (selectedItems.isEmpty) selectionMode = false;
        } else {
          selectedItems.add(id);
        }
      });
    } else {
      // could implement contact details or call
    }
  }

  Future<void> _confirmAndDeleteSelected() async {
    if (selectedItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected contacts?'),
        content: Text('Delete ${selectedItems.length} contact(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _deleteSelectedContacts();
  }

  Future<void> _deleteSelectedContacts() async {
    final url = Uri.parse("$baseUrl/delete-multiple");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ids": selectedItems.toList()}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Contacts deleted')));
          setState(() {
            selectionMode = false;
            selectedItems.clear();
          });
          _fetchContacts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Delete failed')),
          );
        }
      } else {
        debugPrint('Delete error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error while deleting')),
        );
      }
    } catch (e) {
      debugPrint('HTTP error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
    }
  }

  void _clearSelection() {
    setState(() {
      selectionMode = false;
      selectedItems.clear();
    });
  }

  void _selectAllItems() {
    setState(() {
      selectionMode = true;
      selectedItems.clear();
      for (var c in contacts) {
        selectedItems.add(c['_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text('${selectedItems.length} selected')
            : Text('Contacts in ${widget.folder['name']}'),
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _selectAllItems,
                  tooltip: 'Select all',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmAndDeleteSelected,
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Contact Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    hintText: 'Contact Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text('Add Contact'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? const Center(child: Text('No contacts found'))
                : RefreshIndicator(
                    onRefresh: _fetchContacts,
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final id = contact['_id'];
                        final isSelected = selectedItems.contains(id);

                        return ListTile(
                          leading: selectionMode
                              ? Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                )
                              : const Icon(Icons.person),
                          title: Text(contact['c_name'] ?? ''),
                          subtitle: Text(contact['c_phone'] ?? ''),
                          onTap: () => _onItemTap(id),
                          onLongPress: () => _onItemLongPress(id),
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
