import 'package:json_annotation/json_annotation.dart';
import 'attachment.dart';

part 'pin.g.dart';

@JsonSerializable()
class Pin {
  final String id;
  final String title;
  final String body;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pin({
    required this.id,
    required this.title,
    required this.body,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.attachments = attachments ?? [],
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  // Factory-Konstruktor und toJson-Methode werden automatisch generiert
  factory Pin.fromJson(Map<String, dynamic> json) => _$PinFromJson(json);
  Map<String, dynamic> toJson() => _$PinToJson(this);

  Pin copyWith({
    String? id,
    String? title,
    String? body,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pin(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
