// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pin _$PinFromJson(Map<String, dynamic> json) => Pin(
      id: json['id'] as String,
      wallId: json['wallId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      url: json['url'] as String?,
      urlOnly: json['urlOnly'] as bool? ?? false,
      color: Pin._colorFromJson(json['color'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: Pin._dateTimeFromTimestamp(json['createdAt'] as Timestamp),
      updatedAt: Pin._dateTimeFromTimestamp(json['updatedAt'] as Timestamp),
    );

Map<String, dynamic> _$PinToJson(Pin instance) => <String, dynamic>{
      'id': instance.id,
      'wallId': instance.wallId,
      'title': instance.title,
      'body': instance.body,
      'color': Pin._colorToJson(instance.color),
      'url': instance.url,
      'urlOnly': instance.urlOnly,
      'attachments': instance.attachments,
      'createdAt': Pin._timestampFromDateTime(instance.createdAt),
      'updatedAt': Pin._timestampFromDateTime(instance.updatedAt),
    };
