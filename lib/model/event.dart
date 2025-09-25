// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Event {
  final int id;
  final String title;
  final DateTime date;
  final int fraktionID;
  final DateTime gueltigAb;
  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.fraktionID,
    required this.gueltigAb,
  });

  Event copyWith({
    int? id,
    String? title,
    DateTime? date,
    int? fraktionID,
    DateTime? gueltigAb,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      fraktionID: fraktionID ?? this.fraktionID,
      gueltigAb: gueltigAb ?? this.gueltigAb,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'fraktionID': fraktionID,
      'gueltigAb': gueltigAb.millisecondsSinceEpoch,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      fraktionID: map['fraktionID'] as int,
      gueltigAb: DateTime.fromMillisecondsSinceEpoch(map['gueltigAb'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) =>
      Event.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $date, fraktionID: $fraktionID, gueltigAb: $gueltigAb)';
  }

  @override
  bool operator ==(covariant Event other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.date == date &&
        other.fraktionID == fraktionID &&
        other.gueltigAb == gueltigAb;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        date.hashCode ^
        fraktionID.hashCode ^
        gueltigAb.hashCode;
  }
}
