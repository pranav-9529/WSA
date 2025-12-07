import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ContactScreen extends StatefulWidget {
  final Map folder;
  const ContactScreen({super.key, required this.folder});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> contacts = [];
  bool isLoading = true;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String? userID;

  // NEW: Track selected contacts for delete
  List<String> selectedContacts = [];
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------------- LOAD USER ID ----------------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");

    if (userID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please login again.")),
      );
      setState(() => isLoading = false);
      return;
    }

    _fetchContacts();
  }

  // ---------------------- FETCH CONTACTS ----------------------
  Future<void> _fetchContacts() async {
    if (userID == null) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService2.getContacts(
        folderID: widget.folder["id"],
        userID: userID!,
      );

      setState(() {
        contacts = res["contacts"] ?? [];
        selectedContacts.clear();
        selectionMode = false; // Reset selection when refreshing
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading contacts: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------------- ADD CONTACT ----------------------
  Future<void> _addContact() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid name & phone")));
      return;
    }

    try {
      final res = await ApiService2.addContact(
        folderID: widget.folder["id"],
        name: name,
        phone: phone,
        userID: userID!,
      );

      if (res["success"] == true) {
        nameCtrl.clear();
        phoneCtrl.clear();
        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to add contact")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // ---------------------- DELETE MULTIPLE CONTACTS ----------------------
  Future<void> _deleteSelectedContacts() async {
    if (selectedContacts.isEmpty) return;

    try {
      final res = await ApiService2.deleteMultipleContacts(
        folderID: widget.folder["id"],
        contactIDs: selectedContacts,
        userID: userID!,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts deleted successfully")),
        );
        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Deletion failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting contacts: $e")));
    }
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder["folderName"]),
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedContacts,
            ),
        ],
      ),

      body: Column(
        children: [
          // -------- Add Contact --------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Contact Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addContact,
                  child: const Text("Add Contact"),
                ),
              ],
            ),
          ),

          // -------- Contact List --------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? const Center(child: Text("No contacts found"))
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final c = contacts[index];
                      final id = c["_id"];

                      final isSelected = selectedContacts.contains(id);

                      return ListTile(
                        leading: selectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedContacts.add(id);
                                    } else {
                                      selectedContacts.remove(id);
                                    }

                                    if (selectedContacts.isEmpty) {
                                      selectionMode = false;
                                    }
                                  });
                                },
                              )
                            : const Icon(Icons.person),

                        title: Text(c["name"] ?? c["c_name"] ?? "Unnamed"),
                        subtitle: Text(
                          c["phone"] ?? c["c_phone"] ?? "No number",
                        ),

                        onLongPress: () {
                          setState(() {
                            selectionMode = true;
                            selectedContacts.add(id);
                          });
                        },

                        onTap: () {
                          if (selectionMode) {
                            setState(() {
                              if (isSelected) {
                                selectedContacts.remove(id);
                                if (selectedContacts.isEmpty) {
                                  selectionMode = false;
                                }
                              } else {
                                selectedContacts.add(id);
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
