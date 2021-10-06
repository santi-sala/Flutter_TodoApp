class Todo {
  int? id;
  String title;
  DateTime date;
  String? priority;
  int? status; //0 - Incomplete, 1 - Complete

  Todo({required this.title, required this.date, this.priority, this.status});
  Todo.withId({required this.id, required this.title, required this.date, this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    if(id != null) {
      map['id'] = id;
    }

    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status']
    );
  }
}
