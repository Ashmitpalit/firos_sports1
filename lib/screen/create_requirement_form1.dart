
import 'package:flutter/material.dart';
import '../model/food_model.dart';
import '../data/food_data.dart';
import '../utils/constants1.dart';
import '../utils/validators.dart';
import 'map_picker-screen.dart';

class CreateRequirementForm extends StatefulWidget {
  final String currentUser;
  final Function(FoodModel, GroupModel) onCreate;

  const CreateRequirementForm({
    super.key,
    required this.currentUser,
    required this.onCreate,
  });

  @override
  State<CreateRequirementForm> createState() => _CreateRequirementFormState();
}

class _CreateRequirementFormState extends State<CreateRequirementForm> {
  final _formKey = GlobalKey<FormState>();
  String? sportName;
  final TextEditingController organiserController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  String? selectedDescription; // Changed to store dropdown selection
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? latitude;
  double? longitude;

  String? gender;
  String? ageLimit;
  String? paidStatus;

  final List<String> sports = Constants.sports;
  // List of description options for the dropdown
  final List<String> descriptionOptions = [
    'Food companion for Breakfast',
    'Food companion for Lunch',
    'Food companion for Snack',
    'Food companion for Dinner',
  ];

  String getLogoPath(String sport) {
    return "assets/images/${sport.toLowerCase()}.jpg";
  }

  @override
  void initState() {
    super.initState();
    organiserController.text = widget.currentUser;
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTime != null &&
        sportName != null &&
        gender != null &&
        ageLimit != null &&
        paidStatus != null &&
        selectedDescription != null &&
        latitude != null &&
        longitude != null) {
      final eventId = "event${foodData.length + 1}";
      final groupId = "group-${groupData.length + 1}";
      final organiserName = organiserController.text.trim();
      final groupName = groupNameController.text.trim().isEmpty
          ? "Chole-Bhature Group by Demo User"
          : groupNameController.text.trim();
      final newRequirement = FoodModel(
        id: eventId,
        sportName: sportName!,
        logoPath: getLogoPath(sportName!),
        organiserName: organiserName,
        venue: venueController.text.trim(),
        city: cityController.text.trim(),
        description: selectedDescription!, // Use dropdown selection
        date:
            "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
        time: selectedTime!.format(context),
        gender: gender!,
        ageLimit: ageLimit!,
        paidStatus: paidStatus!,
        latitude: latitude!,
        longitude: longitude!,
      );
      final newGroup = GroupModel(
        groupId: groupId,
        eventId: eventId,
        groupName: groupName,
        organiserName: organiserName,
        members: [organiserName],
      );
      widget.onCreate(newRequirement, newGroup);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Requirement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: sportName,
                  items: sports.map((sport) {
                    return DropdownMenuItem(
                      value: sport,
                      child: Text(sport),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => sportName = value),
                  decoration: const InputDecoration(
                    labelText: "Food",
                    prefixIcon: Icon(Icons.local_pizza),
                  ),
                  validator: Validators.validateSport,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: organiserController,
                  decoration: const InputDecoration(
                    labelText: "Organiser Name",
                    prefixIcon: Icon(Icons.person),
                    hintText: "e.g., Demo User",
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: groupNameController,
                  decoration: const InputDecoration(
                    labelText: "Group Name (optional)",
                    prefixIcon: Icon(Icons.group),
                    hintText: "e.g., Weekend Warriors",
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: venueController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Venue",
                    prefixIcon: Icon(Icons.map),
                    hintText: "Tap to pick from map",
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapPickerScreen(),
                      ),
                    );
                    if (result != null && result is Map) {
                      setState(() {
                        venueController.text = result['address'];
                        latitude = result['latitude'];
                        longitude = result['longitude'];
                      });
                    }
                  },
                  validator: Validators.validateVenue,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: "City",
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter city' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDescription,
                  items: descriptionOptions.map((description) {
                    return DropdownMenuItem(
                      value: description,
                      child: Text(description),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedDescription = value),
                  decoration: const InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a description' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ['All', 'Male', 'Female'].map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => gender = value),
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    prefixIcon: Icon(Icons.transgender),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select gender' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ageLimit,
                  items: [
                    '18-25',
                    '26-33',
                    '33-40',
                    '41-50',
                    '50-65',
                    '65+',
                  ].map((age) {
                    return DropdownMenuItem(
                      value: age,
                      child: Text(age),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => ageLimit = value),
                  decoration: const InputDecoration(
                    labelText: "Age Limit",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select age limit' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paidStatus,
                  items: Constants.paidStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => paidStatus = value),
                  decoration: const InputDecoration(
                    labelText: "Paid / Unpaid",
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: Validators.validatePaidStatus,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    labelText: "Date",
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: selectedDate == null
                        ? 'Choose Date'
                        : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                  ),
                  validator: (value) =>
                      selectedDate == null ? 'Please select a date' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: InputDecoration(
                    labelText: "Time",
                    prefixIcon: const Icon(Icons.access_time),
                    hintText: selectedTime == null
                        ? 'Choose Time'
                        : selectedTime!.format(context),
                  ),
                  validator: (value) =>
                      selectedTime == null ? 'Please select a time' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Create"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
