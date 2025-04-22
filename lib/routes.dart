import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteManagementPage extends StatefulWidget {
  const RouteManagementPage({super.key});

  @override
  State<RouteManagementPage> createState() => _RouteManagementPageState();
}

class _RouteManagementPageState extends State<RouteManagementPage> {
  final List<String> _places = [
    'West',
    'Bommanahalli',
    'Mahadevapura',
    'South',
    'RR Nagar',
  ];

  String? _selectedPlace;
  String? _selectedCollectorToAdd;
  String? _selectedCollectorToRemove;
  List<String> _collectors = []; // Contains formatted name + vehicle
  List<String> _selectedCollectorsToAdd = [];
  List<String> _selectedCollectorsToRemove = [];
  List<String> _existingCollectorsInPlace = [];

  @override
  void initState() {
    super.initState();
    fetchCollectors();
  }

  Future<void> fetchCollectors() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'COLLECTOR')
          .get();

      List<String> collectorDisplayList = snapshot.docs.map((doc) {
        String name = doc['name'] ?? 'Unknown';
        String vehicle = doc['vehicleNumber'] ?? 'No vehicle';
        return '$name ($vehicle)';
      }).toList();

      setState(() {
        _collectors = collectorDisplayList;
      });
    } catch (e) {
      print('Error fetching collectors: $e');
    }
  }

  Future<void> fetchExistingCollectorsForPlace(String place) async {
    final placeRef = FirebaseFirestore.instance.collection(place);

    final querySnapshot = await placeRef.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<String> collectors = querySnapshot.docs
          .first
          .get('collectors')
          .map<String>((collector) => collector.toString())
          .toList();
      setState(() {
        _existingCollectorsInPlace = collectors;
      });
    } else {
      setState(() {
        _existingCollectorsInPlace = [];
      });
    }
  }

  Future<void> updatePlaceInFirebase() async {
    if (_selectedPlace == null) return;

    if (_selectedCollectorToAdd == _selectedCollectorToRemove) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot add and remove the same person')),
      );
      return;
    }

    final placeRef = FirebaseFirestore.instance.collection(_selectedPlace!);
    final querySnapshot = await placeRef.get();

    if (querySnapshot.docs.isNotEmpty) {
      final docRef = placeRef.doc(querySnapshot.docs.first.id);

      if (_selectedCollectorsToAdd.isNotEmpty) {
        await docRef.update({
          'collectors': FieldValue.arrayUnion(_selectedCollectorsToAdd),
        });
      }

      if (_selectedCollectorsToRemove.isNotEmpty) {
        await docRef.update({
          'collectors': FieldValue.arrayRemove(_selectedCollectorsToRemove),
        });
      }
    } else {
      if (_selectedCollectorsToAdd.isNotEmpty) {
        await placeRef.add({
          'collectors': _selectedCollectorsToAdd,
        });
      }
    }

    setState(() {
      _selectedCollectorToAdd = null;
      _selectedCollectorToRemove = null;
      _selectedCollectorsToAdd.clear();
      _selectedCollectorsToRemove.clear();
      _existingCollectorsInPlace.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route updated successfully')),
    );
  }

  void addCollectorToAddList(String? collector) {
    if (collector != null && !_selectedCollectorsToAdd.contains(collector)) {
      setState(() {
        _selectedCollectorsToAdd.add(collector);
      });
    }
  }

  void addCollectorToRemoveList(String? collector) {
    if (collector != null &&
        !_selectedCollectorsToRemove.contains(collector)) {
      setState(() {
        _selectedCollectorsToRemove.add(collector);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Route Management',
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

              // Destination dropdown
              _buildDropdownContainer(
                child: DropdownButtonFormField<String>(
                  value: _selectedPlace,
                  hint: const Text("Select a destination"),
                  decoration: const InputDecoration(border: InputBorder.none),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _places.map((place) {
                    return DropdownMenuItem<String>(
                      value: place,
                      child: Text(place),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlace = value;
                      _selectedCollectorToAdd = null;
                      _selectedCollectorToRemove = null;
                      _selectedCollectorsToAdd.clear();
                      _selectedCollectorsToRemove.clear();
                    });
                    fetchExistingCollectorsForPlace(value!);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Add collector dropdown
              _buildDropdownContainer(
                child: DropdownButtonFormField<String>(
                  value: _selectedCollectorToAdd,
                  hint: const Text("Select collector to add"),
                  decoration: const InputDecoration(border: InputBorder.none),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _collectors.map((collector) {
                    return DropdownMenuItem<String>(
                      value: collector,
                      child: Text(collector),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedCollectorToAdd = value;
                    addCollectorToAddList(value);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Remove collector dropdown
              if (_existingCollectorsInPlace.isNotEmpty)
                _buildDropdownContainer(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCollectorToRemove,
                    hint: const Text("Select collector to remove"),
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _existingCollectorsInPlace.map((collector) {
                      return DropdownMenuItem<String>(
                        value: collector,
                        child: Text(collector),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedCollectorToRemove = value;
                      addCollectorToRemoveList(value);
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Selected collectors chips
              if (_selectedCollectorsToAdd.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedCollectorsToAdd.map((collector) {
                    return Chip(
                      label: Text('Add: $collector'),
                      onDeleted: () {
                        setState(() {
                          _selectedCollectorsToAdd.remove(collector);
                        });
                      },
                    );
                  }).toList(),
                ),
              if (_selectedCollectorsToRemove.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedCollectorsToRemove.map((collector) {
                    return Chip(
                      label: Text('Remove: $collector'),
                      onDeleted: () {
                        setState(() {
                          _selectedCollectorsToRemove.remove(collector);
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: updatePlaceInFirebase,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
