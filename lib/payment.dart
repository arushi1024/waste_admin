import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({Key? key}) : super(key: key);

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  String? selectedDriverId;
  String? selectedDriverName;
  List<String> attendanceDates = [];
  bool isLoading = false;
  List<Map<String, dynamic>> collectors = [];
  double totalPayment = 0.0;

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
      totalPayment = 0.0; // Reset total payment
    });

    final doc = await FirebaseFirestore.instance.collection('attendance').doc(uid).get();

    if (doc.exists && doc.data()?['attendance'] != null) {
      final List<dynamic> dates = doc['attendance'];
      setState(() {
        attendanceDates = List<String>.from(dates);
        // Calculate total payment based on attendance (100 rupees per present day)
        totalPayment = attendanceDates.length * 100.0;
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
          "Payroll Tracker",
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
              "Select a driver to view their payroll details.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDriverId,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Select Driver",
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
                  selectedDriverId = value;
                  selectedDriverName = selected['name'];
                });
                fetchAttendance(value!);
              },
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (selectedDriverId != null)
              Expanded(
                child: attendanceDates.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payroll for $selectedDriverName",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Attendance Table
                                const Text(
                                  "Attendance and Payment Breakdown",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: attendanceDates.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 6),
                                        padding: const EdgeInsets.all(12),
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
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              attendanceDates[index],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              "₹ 100",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Total Payment
                                Text(
                                  "Total Payment: ₹ ${totalPayment.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
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
