import 'package:flutter/material.dart';
import 'package:waste_management_admin/attendance.dart';
import 'package:waste_management_admin/complaints.dart';
import 'package:waste_management_admin/payment.dart';
import 'package:waste_management_admin/routes.dart';
import 'package:waste_management_admin/users.dart';
import 'package:waste_management_admin/view_routes.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

 final List<_AdminOption> options = const [
  _AdminOption("Routes", Icons.alt_route, "/routesPage"),
  _AdminOption("Manage Drivers", Icons.directions_bus, "/driversPage"),
  _AdminOption("Users", Icons.people, "/usersPage"),
  _AdminOption("Complaints", Icons.report_problem, "/complaintsPage"),
  _AdminOption("Attendance", Icons.calendar_today, "/attendancePage"),
  _AdminOption("Payrolls", Icons.payment, "/payrollsPage"), // New Payroll option
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: const Icon(Icons.admin_panel_settings, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Admin 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Manage and monitor your platform from here.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => RouteOverviewPage(),
                          ),
                        );
                      }
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => RouteManagementPage(),
                          ),
                        );
                      }
                      if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => ViewUsersPage(),
                          ),
                        );
                      }
                      if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => ComplaintsPage(),
                          ),
                        );
                      }
                      if (index == 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => AttendancePage(),
                          ),
                        );
                      }
                      if (index == 5) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => PayrollPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green[50],
                            radius: 28,
                            child: Icon(
                              option.icon,
                              size: 28,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            option.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption {
  final String title;
  final IconData icon;
  final String route;

  const _AdminOption(this.title, this.icon, this.route);
}
