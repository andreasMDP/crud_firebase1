import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  CollectionReference _users = FirebaseFirestore.instance.collection("users");

  void _addUser() {
    _users.add({
      'name': _nameController.text,
      'profession': _professionController.text,
    });
    _nameController.clear();
    _professionController.clear();
  }

  void _deleteUser(String userId) {
    _users.doc(userId).delete();
  }

  void _editUser(DocumentSnapshot user) {
    _nameController.text = user['name'];
    _professionController.text = user['profession'];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "User Name"),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _professionController,
                  decoration: InputDecoration(labelText: "User Profession"),
                ),
                SizedBox(height: 8),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    _updateUser(user.id);
                    Navigator.pop(context);
                  },
                  child: Text("Update")),
            ],
          );
        });
  }

  void _updateUser(String userId) {
    _users.doc(userId).update({
      'name': _nameController.text,
      'profession': _professionController.text
    });

    _nameController.clear();
    _professionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD App"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Enter User Name"),
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _professionController,
              decoration: InputDecoration(labelText: "Enter User Profession"),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _addUser();
              },
              child: Text("Add User"),
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
                child: StreamBuilder(
              stream: _users.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data!.docs[index];
                    return Dismissible(
                      key: Key(user.id),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteUser(user.id);
                      },
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            user['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            user['profession'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _editUser(user);
                            },
                            icon: Icon(Icons.edit),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
