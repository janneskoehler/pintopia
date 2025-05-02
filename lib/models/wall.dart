import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pintopia/services/storage_service.dart';

part 'wall.g.dart';

@JsonSerializable()
class Wall {
  final String id;
  final String title;
  final String? imageUrl;
  final String? assetImageName;
  final String adminCode;

  static String generateAdminCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<int> countNewPinsSinceLastVisit(StorageService storageService) async {
    final lastOpened = await storageService.getLastOpenedWallTime(id);
    if (lastOpened == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('walls')
        .doc(id)
        .collection('pins')
        .where('createdAt', isGreaterThan: lastOpened)
        .get();

    return snapshot.docs.length;
  }

  Wall({
    required this.id,
    required this.title,
    this.imageUrl,
    this.assetImageName,
    required this.adminCode,
  });

  // Factory constructor and toJson method are automatically generated
  factory Wall.fromJson(Map<String, dynamic> json) => _$WallFromJson(json);
  Map<String, dynamic> toJson() => _$WallToJson(this);

  Wall copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? assetImageName,
    String? adminCode,
  }) {
    return Wall(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      assetImageName: assetImageName ?? this.assetImageName,
      adminCode: adminCode ?? this.adminCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'assetImageName': assetImageName,
      'adminCode': adminCode,
    };
  }

  factory Wall.fromMap(Map<String, dynamic> map) {
    return Wall(
      id: map['id'] as String,
      title: map['title'] as String,
      imageUrl: map['imageUrl'] as String?,
      assetImageName: map['assetImageName'] as String?,
      adminCode: map['adminCode'] as String,
    );
  }
}
