import '../model/companion_model.dart';

final List<CompanionModel> companionData = [
  CompanionModel(
    id: "event1",
    sportName: "Football",
    logoPath: "assets/images/football.jpg",
    organiserName: "Demo User",
    venue: "Nehru Stadium",
    city: "Delhi",
    description: "Looking for passionate football players for a weekend match.",
    date: "2025-05-18",
    time: "5:00 PM",
    gender: "Any",
    ageLimit: "18-30",
    paidStatus: "Unpaid",
    latitude: 28.5829,
    longitude: 77.2334,
  ),
  CompanionModel(
    id: "event2",
    sportName: "Cricket",
    logoPath: "assets/images/cricket.jpg",
    organiserName: "Rahul Verma",
    venue: "Maidan Ground",
    city: "Mumbai",
    description: "Join our Sunday cricket league, open for all.",
    date: "2025-05-20",
    time: "10:00 AM",
    gender: "Male",
    ageLimit: "18-30",
    paidStatus: "Paid",
    latitude: 18.9389,
    longitude: 72.8258,
  ),
  CompanionModel(
    id: "event3",
    sportName: "Badminton",
    logoPath: "assets/images/badminton.jpg",
    organiserName: "Sneha Roy",
    venue: "Sports Complex",
    city: "Bangalore",
    description: "Join our badminton doubles match!",
    date: "2025-05-22",
    time: "6:00 PM",
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
