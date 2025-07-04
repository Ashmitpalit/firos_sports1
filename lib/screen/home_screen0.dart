import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/companion_card.dart';
import '../widgets/circular_avatar.dart';
import 'create_requirement_form.dart';
import 'view_groups_screen.dart';
import 'profile_screen.dart';
import '../providers/user_provider.dart';

class SportMainScreen extends StatefulWidget {
  const SportMainScreen({super.key});

  @override
  State<SportMainScreen> createState() => _SportMainScreenState();
}

class _SportMainScreenState extends State<SportMainScreen> {
  String? selectedCity;
  String? selectedSport;

  String gender = 'All';
  String age = 'All';
  String type = 'All';
  DateTime? selectedDate;
  double distance = 0;

  List<dynamic> allData = [];
  List<dynamic> filteredData = [];
  List<String> debugLogs = [];

  bool isDistanceActive = false;
  bool isLoading = true;
  bool showLogs = true;

  final List<String> cityOptions = [
    'Ahmedabad', 'Bangalore', 'Bhopal', 'Chandigarh', 'Chennai',
    'Delhi', 'Hyderabad', 'Indore', 'Jaipur', 'Kanpur',
    'Kochi', 'Kolkata', 'Lucknow', 'Mumbai', 'Nagpur',
    'Patna', 'Pune', 'Ranchi', 'Surat', 'Visakhapatnam',
  ];

  final List<String> sportOptions = [
    'Badminton', 'Basketball', 'Boxing', 'Chess', 'Cricket',
    'Cycling', 'Football', 'Gym', 'Hockey', 'Kabaddi',
    'Martial Arts', 'PUBG', 'Running', 'Skating', 'Swimming',
    'Table Tennis', 'Tennis', 'Volleyball', 'Weightlifting', 'Yoga',
  ];

  void log(String msg) {
    print(msg);
    setState(() {
      debugLogs.add("[${DateFormat.Hms().format(DateTime.now())}] $msg");
      if (debugLogs.length > 100) debugLogs.removeAt(0);
    });
  }

  @override
  void initState() {
    super.initState();
    log("INIT: SportMainScreen Started");
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    log("Fetching data from Firebase...");

    try {
      final url = Uri.parse('https://sportface-f9594-default-rtdb.firebaseio.com/requirements.json');
      final response = await http.get(url);
      log("HTTP status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        log("Decoded JSON: ${decoded.runtimeType}");

        if (decoded != null && decoded is Map<String, dynamic>) {
          final now = DateTime.now();

          final items = decoded.entries.map((e) {
            final value = e.value as Map<String, dynamic>? ?? {};
            final timestamp = DateTime.tryParse(value['timestamp'] ?? '') ?? now;
            final timer = value['timer'] ?? 0;
            final endTime = timestamp.add(Duration(hours: timer));
            if (endTime.isAfter(now)) {
              return {
                'id': e.key,
                ...value,
                'endTime': endTime.toIso8601String(),
              };
            } else {
              return null;
            }
          }).where((e) => e != null).cast<Map<String, dynamic>>().toList();

          log("Parsed ${items.length} items");

          setState(() {
            allData = items;
            filteredData = items;
          });
        } else {
          log("Empty or malformed response");
        }
      } else {
        log("Non-200 response: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception during fetch: $e");
    } finally {
      setState(() => isLoading = false);
      log("Fetch complete");
    }
  }

  void applyFilters() {
    List<dynamic> results = List.from(allData);

    if (!isDistanceActive && selectedCity != null && selectedCity!.isNotEmpty) {
      results = results.where((item) =>
        (item['city'] ?? '').toString().toLowerCase().contains(selectedCity!.toLowerCase())).toList();
    }

    if (selectedSport != null && selectedSport!.isNotEmpty) {
      results = results.where((item) =>
        (item['sport'] ?? '').toString().toLowerCase().contains(selectedSport!.toLowerCase())).toList();
    }

    if (gender != 'All') {
      results = results.where((item) => item['gender'] == gender).toList();
    }

    if (age != 'All') {
      results = results.where((item) => item['ageLimit'] == age).toList();
    }

    if (type != 'All') {
      results = results.where((item) => item['type'] == type).toList();
    }

    if (selectedDate != null) {
      results = results.where((item) =>
        item['date'] != null &&
        item['date'] == DateFormat('yyyy-MM-dd').format(selectedDate!)).toList();
    }

    log("Filters applied: ${results.length} items");

    setState(() {
      filteredData = results;
    });
  }

  void resetFilters() {
    selectedCity = null;
    selectedSport = null;
    gender = 'All';
    age = 'All';
    type = 'All';
    selectedDate = null;
    distance = 0;
    isDistanceActive = false;

    setState(() => filteredData = allData);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Sport Companions"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (user != null)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularAvatar(imageUrl: user.imageUrl, userId: user.id),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateRequirementScreen()),
                    );
                    await fetchData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ViewGroupsScreen()),
                    );
                  },
                  icon: const Icon(Icons.group),
                  label: const Text("Groups"),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              "Filters",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (!isDistanceActive)
                  DropdownButtonFormField(
                    value: selectedCity,
                    items: cityOptions
                        .map((val) => DropdownMenuItem(
                              value: val,
                              child: Text(
                                val,
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCity = val),
                    decoration: const InputDecoration(
                      labelText: 'City',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                    ),
                  ),
                DropdownButtonFormField(
                  value: selectedSport,
                  items: sportOptions
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedSport = val),
                  decoration: const InputDecoration(
                    labelText: 'Sport',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    prefixIcon: Icon(Icons.sports, color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField(
                  value: gender,
                  items: ['All', 'Male', 'Female']
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => gender = val!),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                  ),
                ),
                DropdownButtonFormField(
                  value: age,
                  items: ['All', '18-25', '26-33', '34-40', '40+']
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => age = val!),
                  decoration: const InputDecoration(
                    labelText: 'Age Limit',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    prefixIcon: Icon(Icons.cake, color: Colors.blueAccent),
                  ),
                ),
                DropdownButtonFormField(
                  value: type,
                  items: ['All', 'Paid', 'Unpaid']
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => type = val!),
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    prefixIcon: Icon(Icons.payment, color: Colors.blueAccent),
                  ),
                ),
                ListTile(
                  title: Text(
                    selectedDate != null
                        ? "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                        : "Select Date",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                ),
                Text(
                  "Distance: ${distance.toInt()} km",
                  style: const TextStyle(color: Colors.blueAccent),
                ),
                Slider(
                  value: distance,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: "${distance.toInt()} km",
                  onChanged: (val) {
                    setState(() {
                      distance = val;
                      isDistanceActive = val > 0;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset"),
                    ),
                    ElevatedButton.icon(
                      onPressed: applyFilters,
                      icon: const Icon(Icons.filter_alt),
                      label: const Text("Apply"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filteredData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No companions found")),
                  )
                else
                  ...filteredData.map((item) {
                    try {
                      return CompanionCard(
                        data: Map<String, dynamic>.from(item),
                        onDeleted: () async {
                          await fetchData();
                        },
                      );
                    } catch (e) {
                      log("Error rendering item: $e");
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("⚠️ Error rendering item"),
                      );
                    }
                  }).toList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Container(
            color: Colors.black87,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => showLogs = !showLogs),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      showLogs ? "🔽 Hide Logs" : "🔼 Show Logs",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                if (showLogs)
                  SizedBox(
                    height: 140,
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: debugLogs
                          .reversed
                          .map((line) => Text(line, style: const TextStyle(color: Colors.white, fontSize: 11)))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
