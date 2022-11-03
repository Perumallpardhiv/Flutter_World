import 'package:assets_audio_player/assets_audio_player.dart';

class AlarmInfo {
  int id;
  String? title;
  String? body;
  DateTime? alarmDateTime;
  int? isPending;
  int? isRepeat;
  String? notifSound;
  int? gradientColorIndex;

  AlarmInfo(
      {required this.id,
      this.title,
      this.body,
      this.alarmDateTime,
      this.isPending,
      this.isRepeat,
      this.notifSound,
      this.gradientColorIndex});

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        isPending: json["isPending"],
        isRepeat: json["isRepeat"],
        notifSound: json["notifSound"],
        gradientColorIndex: json["gradientColorIndex"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "body": body,
        "alarmDateTime": alarmDateTime!.toIso8601String(),
        "isPending": isPending,
        "isRepeat": isRepeat,
        "notifSound": notifSound,
        "gradientColorIndex": gradientColorIndex,
      };
}
