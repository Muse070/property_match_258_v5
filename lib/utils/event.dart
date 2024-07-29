class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final List<String> participants; // This could be a list of user IDs.
  final String status;

  Event({required this.id,
      required this.title,
      required this.description,
      required this.startTime,
      required this.endTime,
      this.location,
      required this.participants,
      required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'participants': participants,
      'status': status,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: map['startTime'].toDate(),
      endTime: map['endTime'].toDate(),
      location: map['location'],
      participants: List<String>.from(map['participants']),
      status: map['status'],
    );
  }

}
