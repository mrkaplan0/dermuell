// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dermuell/model/adresse.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String role;
  Adresse? adresse;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.adresse,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    Adresse? adresse,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      adresse: adresse ?? this.adresse,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'adresse': adresse?.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      adresse: map['adresse'] != null
          ? Adresse.fromMap(map['adresse'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, password: $password, role: $role, adresse: $adresse)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.role == role &&
        other.adresse == adresse;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        role.hashCode ^
        adresse.hashCode;
  }
}
