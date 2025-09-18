// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Adresse {
  String strasse;
  String hausnummer;
  String plz;
  String stadt;
  Adresse({
    required this.strasse,
    required this.hausnummer,
    required this.plz,
    required this.stadt,
  });

  Adresse copyWith({
    String? strasse,
    String? hausnummer,
    String? plz,
    String? stadt,
  }) {
    return Adresse(
      strasse: strasse ?? this.strasse,
      hausnummer: hausnummer ?? this.hausnummer,
      plz: plz ?? this.plz,
      stadt: stadt ?? this.stadt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'strasse': strasse,
      'hausnummer': hausnummer,
      'plz': plz,
      'stadt': stadt,
    };
  }

  factory Adresse.fromMap(Map<String, dynamic> map) {
    return Adresse(
      strasse: map['strasse'] as String,
      hausnummer: map['hausnummer'] as String,
      plz: map['plz'] as String,
      stadt: map['stadt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Adresse.fromJson(String source) =>
      Adresse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Adresse(strasse: $strasse, hausnummer: $hausnummer, plz: $plz, stadt: $stadt)';
  }

  @override
  bool operator ==(covariant Adresse other) {
    if (identical(this, other)) return true;

    return other.strasse == strasse &&
        other.hausnummer == hausnummer &&
        other.plz == plz &&
        other.stadt == stadt;
  }

  @override
  int get hashCode {
    return strasse.hashCode ^
        hausnummer.hashCode ^
        plz.hashCode ^
        stadt.hashCode;
  }
}
