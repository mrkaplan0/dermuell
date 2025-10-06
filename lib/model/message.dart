// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dermuell/model/comment.dart';

class Message {
  final int id;
  final int user_id;
  final String username;
  final String title;
  final String content;
  final DateTime createdAt;
  DateTime willDeleteAt;
  int recycleCount;
  int commentCount;
  int deleteCount;
  List<Comment>? comments;
  Message({
    required this.id,
    required this.user_id,
    required this.username,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.willDeleteAt,
    required this.recycleCount,
    required this.commentCount,
    required this.deleteCount,
    this.comments,
  });

  Message copyWith({
    int? id,
    int? user_id,
    String? username,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? willDeleteAt,
    int? recycleCount,
    int? commentCount,
    int? deleteCount,
    List<Comment>? comments,
  }) {
    return Message(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      username: username ?? this.username,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      willDeleteAt: willDeleteAt ?? this.willDeleteAt,
      recycleCount: recycleCount ?? this.recycleCount,
      commentCount: commentCount ?? this.commentCount,
      deleteCount: deleteCount ?? this.deleteCount,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': user_id,
      'username': username,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'willDeleteAt': willDeleteAt.millisecondsSinceEpoch,
      'recycleCount': recycleCount,
      'commentCount': commentCount,
      'deleteCount': deleteCount,
      'comments': comments?.map((x) => x.toMap()).toList(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      user_id: map['user_id'] as int,
      username: map['username'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      willDeleteAt: DateTime.fromMillisecondsSinceEpoch(
        map['willDeleteAt'] as int,
      ),
      recycleCount: map['recycleCount'] as int,
      commentCount: map['commentCount'] as int,
      deleteCount: map['deleteCount'] as int,
      comments: map['comments'] != null
          ? List<Comment>.from(
              (map['comments'] as List<int>).map<Comment?>(
                (x) => Comment.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, user_id: $user_id, username: $username, title: $title, content: $content, createdAt: $createdAt, willDeleteAt: $willDeleteAt, recycleCount: $recycleCount, commentCount: $commentCount, deleteCount: $deleteCount, comments: $comments)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user_id == user_id &&
        other.username == username &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.willDeleteAt == willDeleteAt &&
        other.recycleCount == recycleCount &&
        other.commentCount == commentCount &&
        other.deleteCount == deleteCount &&
        listEquals(other.comments, comments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user_id.hashCode ^
        username.hashCode ^
        title.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        willDeleteAt.hashCode ^
        recycleCount.hashCode ^
        commentCount.hashCode ^
        deleteCount.hashCode ^
        comments.hashCode;
  }
}
