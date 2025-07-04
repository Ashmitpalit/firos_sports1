class TravelModel {
  final String id;
  final String sportName;
  final String logoPath;
  final String organiserName;
  final String venue;
  final String city;
  final String description;
  final String date;
  final String time;
  final String gender;
  final String ageLimit;
  final String paidStatus;
  final double latitude;
  final double longitude;

  TravelModel({
    required this.id,
    required this.sportName,
    required this.logoPath,
    required this.organiserName,
    required this.venue,
    required this.city,
    required this.description,
    required this.date,
    required this.time,
    required this.gender,
    required this.ageLimit,
    required this.paidStatus,
    required this.latitude,
    required this.longitude,
  });
}

class GroupModel {
  final String groupId;
  final String eventId;
  final String groupName;
  final String organiserName;
  final List<String> members;

  GroupModel({
    required this.groupId,
    required this.eventId,
    required this.groupName,
    required this.organiserName,
    required this.members,
  });
}

class PendingRequest {
  final String userName;
  final String groupId;

  PendingRequest({
    required this.userName,
    required this.groupId,
  });
}

class MessageModel {
  final String sender;
  final String text;
  final String timestamp;

  MessageModel({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}
