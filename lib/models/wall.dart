import 'package:json_annotation/json_annotation.dart';

part 'wall.g.dart';

@JsonSerializable()
class Wall {
  final String id;
  final String title;
  final String? imageUrl;
  final String? assetImageName;

  Wall({
    required this.id,
    required this.title,
    this.imageUrl,
    this.assetImageName,
  });

  // Factory-Konstruktor und toJson-Methode werden automatisch generiert
  factory Wall.fromJson(Map<String, dynamic> json) => _$WallFromJson(json);
  Map<String, dynamic> toJson() => _$WallToJson(this);

  Wall copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? assetImageName,
  }) {
    return Wall(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      assetImageName: assetImageName ?? this.assetImageName,
    );
  }
}
