import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedUserId;
  String? selectedUserName;
  List<String> attendanceDates = [];
  List<Map<String, dynamic>> collectors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCollectors();
  }

  Future<void> fetchCollectors() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'COLLECTOR')
        .get();

    final fetchedCollectors = querySnapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'name': doc['name'],
      };
    }).toList();

    setState(() {
      collectors = fetchedCollectors;
    });
  }

  Future<void> fetchAttendance(String uid) async {
    setState(() {
      isLoading = true;
      attendanceDates = [];
    });

    final doc = await FirebaseFirestore.instance.collection('attendance').doc(uid).get();

    if (doc.exists && doc.data()?['attendance'] != null) {
      final List<dynamic> dates = doc['attendance'];
      setState(() {
        attendanceDates = List<String>.from(dates);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FD),
      appBar: AppBar(
        title: const Text(
          "Attendance Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const Text(
              "Select a collector to view their attendance records.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedUserId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Select Collector",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: collectors.map((collector) {
                return DropdownMenuItem<String>(
                  value: collector['uid'],
                  child: Text(collector['name']),
                );
              }).toList(),
              onChanged: (value) {
                final selected = collectors.firstWhere((c) => c['uid'] == value);
                setState(() {
                  selectedUserId = value;
                  selectedUserName = selected['name'];
                });
                fetchAttendance(value!);
              },
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (selectedUserId != null)
              Expanded(
                child: attendanceDates.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance for $selectedUserName",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: GridView.builder(
                              itemCount: attendanceDates.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3.5,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      attendanceDates[index],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No attendance data found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
