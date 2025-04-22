import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteOverviewPage extends StatefulWidget {
  const RouteOverviewPage({super.key});

  @override
  State<RouteOverviewPage> createState() => _RouteOverviewPageState();
}

class _RouteOverviewPageState extends State<RouteOverviewPage> {
  final List<String> _places = [
    'West',
    'Bommanahalli',
    'Mahadevapura',
    'South',
    'RR Nagar',
  ];

  Map<String, List<String>> _routeCollectors = {};

  @override
  void initState() {
    super.initState();
    fetchRouteCollectors();
  }

  // Fetch collectors for each route
  Future<void> fetchRouteCollectors() async {
    try {
      for (var place in _places) {
        final placeRef = FirebaseFirestore.instance.collection(place);
        final querySnapshot = await placeRef.get();

        if (querySnapshot.docs.isNotEmpty) {
          List<String> collectors = querySnapshot.docs
              .first
              .get('collectors')
              .map<String>((collector) => collector.toString())
              .toList();
          setState(() {
            _routeCollectors[place] = collectors;
          });
        }
      }
    } catch (e) {
      print('Error fetching route collectors: $e');
    }
  }

  // Fetch customers based on block
  Future<void> _showCustomersForRoute(String place) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final querySnapshot =
          await usersRef.where('block', isEqualTo: place).get();

      List<Map<String, dynamic>> customers = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Customers in $place',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (customers.isEmpty)
                    const Text("No customers found.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(customer['name'] ?? 'No name'),
                          subtitle: Text(customer['address'] ?? 'No address'),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error fetching customers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load customers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Route Overview',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/image 5.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  final place = _places[index];
                  final collectors = _routeCollectors[place];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (collectors != null && collectors.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: collectors.map((collector) {
                                return Chip(
                                  label: Text(collector),
                                  backgroundColor: Colors.blue.shade100,
                                );
                              }).toList(),
                            )
                          else
                            const Text('No collectors assigned yet'),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _showCustomersForRoute(place),
                              icon: const Icon(Icons.people),
                              label: const Text('View Customers'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
