import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

enum AttachmentType { image, file }

@JsonSerializable()
class Attachment {
  final String url;
  final AttachmentType type;
  final String? fileName; // Optional, mainly for files
  final String? mimeType; // For file type identification

  Attachment({
    required this.url,
    required this.type,
    this.fileName,
    this.mimeType,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
