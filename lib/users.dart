import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({super.key});

  @override
  State<ViewUsersPage> createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<List<Map<String, dynamic>>> fetchUsers(String userType) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .where((doc) =>
            (doc.data()['userType']?.toString().toUpperCase() ?? '') ==
            userType.toUpperCase())
        .map((doc) => doc.data())
        .toList();
  }

  Widget buildUserList(String userType) {
    return FutureBuilder<List<Map<String, dynamic>>>( 
      future: fetchUsers(userType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  user['name'] ?? 'No Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  user['email'] ?? 'No Email',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Chip(
                  label: Text(
                    user['block'] ?? 'Active',
                    style: TextStyle(
                      color: user['block'] == 'Active'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        // backgroundColor: const Color.fromARGB(255, 18, 150, 65),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              text: 'Collectors',
              icon: Icon(Icons.group),
            ),
            Tab(
              text: 'Customers',
              icon: Icon(Icons.people),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildUserList('COLLECTOR'),
          buildUserList('CUSTOMER'),
        ],
      ),
    );
  }
}
