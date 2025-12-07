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

    if (userID == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID missing")));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact added successfully")),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder["folderName"])),

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
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c["name"] ?? c["c_name"] ?? "Unnamed"),
                        subtitle: Text(
                          c["phone"] ?? c["c_phone"] ?? "No number",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
