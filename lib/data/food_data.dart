import '../model/food_model.dart';

final List<FoodModel> foodData = [
  FoodModel(
    id: "event1",
    sportName: "Snacks",
    logoPath: "assets/images/Snacks.png",
    organiserName: "Demo User",
    venue: "Olive Bar and kitchen",
    city: "Delhi",
    description: "Looking for food companion for Snack.",
    date: "2025-05-18",
    time: "5:00 PM",
    gender: "Any",
    ageLimit: "18-30",
    paidStatus: "Unpaid",
    latitude: 28.5829,
    longitude: 77.2334,
  ),
  FoodModel(
    id: "event2",
    sportName: "Lunch",
    logoPath: "assets/images/Lunch1.png",
    organiserName: "Rahul Verma",
    venue: "Bombay Fries",
    city: "Mumbai",
    description: "Looking for food companion for Lunch.",
    date: "2025-05-20",
    time: "2:00 PM",
    gender: "Male",
    ageLimit: "18-30",
    paidStatus: "Paid",
    latitude: 18.9389,
    longitude: 72.8258,
  ),
  FoodModel(
    id: "event3",
    sportName: "Drinks",
    logoPath: "assets/images/Drinks.png",
    organiserName: "Sneha Roy",
    venue: "Food Complex",
    city: "Bangalore",
    description: "Looking for food companion for Drinks.",
    date: "2025-05-22",
    time: "9:00 PM",
    gender: "Female",
    ageLimit: "18-30",
    paidStatus: "Unpaid",
    latitude: 12.9716,
    longitude: 77.5946,
  ),
];

final List<GroupModel> groupData = [
  GroupModel(
    groupId: "group1",
    eventId: "event1",
    groupName: "Football Group by Demo User",
    organiserName: "Demo User",
    members: ["Demo User", "Sneha Roy"],
  ),
  GroupModel(
    groupId: "group2",
    eventId: "event2",
    groupName: "Cricket League by Rahul",
    organiserName: "Rahul Verma",
    members: ["Rahul Verma"],
  ),
  GroupModel(
    groupId: "group3",
    eventId: "event3",
    groupName: "Badminton Group by Sneha",
    organiserName: "Sneha Roy",
    members: ["Sneha Roy"],
  ),
];

final List<PendingRequest> pendingRequests = [
  PendingRequest(
    userName: "Rahul Verma",
    groupId: "group1",
  ),
];

final Map<String, List<MessageModel>> groupMessages = {
  "group1": [
    MessageModel(
      sender: "Demo User",
      text: "Hey, excited for the match?",
      timestamp: "2025-05-17 10:00 AM",
    ),
    MessageModel(
      sender: "Sneha Roy",
      text: "Absolutely, let's win this!",
      timestamp: "2025-05-17 10:05 AM",
    ),
  ],
};

final List<String> availableUsers = [
  "Demo User",
  "Sneha Roy",
  "Rahul Verma",
];

void logGroupData(String context) {
  print("Group Data ($context):");
  for (var group in groupData) {
    print(
        "Group ${group.groupId}: Name=${group.groupName}, Organiser=${group.organiserName}, Members=${group.members}");
  }
}
