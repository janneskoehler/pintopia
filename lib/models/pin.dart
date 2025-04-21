import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'attachment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'pin.g.dart';

@JsonSerializable()
class Pin {
  final String id;
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
    required this.title,
    required this.body,
    Color? color,
    this.url,
    bool? urlOnly,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.color = color ?? Colors.white,
        this.urlOnly = urlOnly ?? false,
        this.attachments = attachments ?? [],
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

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

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) =>
      timestamp.toDate();
  static Timestamp _timestampFromDateTime(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);

  Pin copyWith({
    String? id,
    String? title,
    String? body,
    Color? color,
    String? url,
    bool? urlOnly,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pin(
      id: id ?? this.id,
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
