import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Format the Firestore timestamp
  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  // Fetch complaints based on status ('open' or 'closed')
  Future<List<Map<String, dynamic>>> fetchComplaintsByStatus(String status) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .where('status', isEqualTo: status)
        .get();

    // Adding the document ID to each complaint data
    return snapshot.docs.map((doc) {
      var complaintData = doc.data();
      complaintData['id'] = doc.id; // Adding document ID
      return complaintData;
    }).toList();
  }

  // Update complaint status to 'closed'
  Future<void> updateComplaintStatus(String complaintId) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({'status': 'closed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint status updated to closed.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating complaint status.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Open Complaints'),
            Tab(text: 'Closed Complaints'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintsList('open'),
          _buildComplaintsList('closed'),
        ],
      ),
    );
  }

  // Build the complaint list for each status ('open' or 'closed')
  Widget _buildComplaintsList(String status) {
    return FutureBuilder(
      future: fetchComplaintsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading complaints"));
        }

        final complaints = snapshot.data as List<Map<String, dynamic>>;

        if (complaints.isEmpty) {
          return const Center(child: Text("No complaints found."));
        }

        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            final complaintId = complaint['id']; // Document ID
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon based on complaint status
                    CircleAvatar(
                      backgroundColor: status == 'open' ? Colors.red : Colors.green,
                      child: Icon(
                        status == 'open' ? Icons.warning_amber_rounded : Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint['vehicleNumber'] ?? 'Unknown Vehicle',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Reason: ${complaint['reason'] ?? 'No Reason Provided'}"),
                          const SizedBox(height: 4),
                          Text("Location: ${complaint['location'] ?? 'No Location Provided'}"),
                          const SizedBox(height: 4),
                          Text("Status: ${complaint['status'] ?? 'No Status'}"),
                          const SizedBox(height: 4),
                          Text("Filed on: ${formatTimestamp(complaint['timestamp'])}"),
                        ],
                      ),
                    ),
                    if (status == 'open')
                      ElevatedButton(
                        onPressed: () => updateComplaintStatus(complaintId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Close Complaint',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
