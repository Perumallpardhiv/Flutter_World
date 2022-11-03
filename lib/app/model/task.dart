class Task {
  int? id;
  int? isCompleted;
  int? color;
  String? note;
  String? date;
  String? startTime;
  String? endTime;
  String? repeat;
  String? title;

  Task(
      {this.id,
      this.isCompleted,
      this.color,
      this.note,
      this.date,
      this.startTime,
      this.endTime,
      this.repeat,
      this.title});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['isCompleted'] = isCompleted;
    data['color'] = color;
    data['note'] = note;
    data['date'] = date;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['repeat'] = repeat;
    data['title'] = title;
    return data;
  }

  Task.fromJson(json) {
    id = json['id'];
    isCompleted = json['isCompleted'];
    color = json['color'];
    note = json['note'].toString();
    date = json['date'].toString();
    startTime = json['startTime'].toString();
    endTime = json['endTime'].toString();
    repeat = json['repeat'].toString();
    title = json['title'].toString();
  }
}
