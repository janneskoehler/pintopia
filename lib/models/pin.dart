import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'attachment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'pin.g.dart';

@JsonSerializable()
class Pin {
  final String id;
  final String wallId;
  final String title;
  final String body;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;
  final String? url;
  final bool urlOnly;
  final List<Attachment> attachments;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _timestampFromDateTime)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _timestampFromDateTime)
  final DateTime updatedAt;

  Pin({
    required this.id,
    required this.wallId,
    required this.title,
    required this.body,
    this.url,
    this.urlOnly = false,
    required this.color,
    this.attachments = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory-Konstruktor und toJson-Methode werden automatisch generiert
  factory Pin.fromJson(Map<String, dynamic> json) => _$PinFromJson(json);
  Map<String, dynamic> toJson() => _$PinToJson(this);

  // Für die JSON-Serialisierung
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  Color get colorValue => color;

  static Color _colorFromJson(Map<String, dynamic> json) => Color.fromARGB(
        ((json['a'] as num) * 255).round(),
        ((json['r'] as num) * 255).round(),
        ((json['g'] as num) * 255).round(),
        ((json['b'] as num) * 255).round(),
      );

  static Map<String, dynamic> _colorToJson(Color color) => {
        'a': color.a,
        'r': color.r,
        'g': color.g,
        'b': color.b,
      };

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static Timestamp _timestampFromDateTime(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  Pin copyWith({
    String? id,
    String? wallId,
    String? title,
    String? body,
    String? url,
    bool? urlOnly,
    Color? color,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pin(
      id: id ?? this.id,
      wallId: wallId ?? this.wallId,
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      url: url ?? this.url,
      urlOnly: urlOnly ?? this.urlOnly,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
