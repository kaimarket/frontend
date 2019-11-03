// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return Chat(
    id: json['id'] as int,
    seller: json['seller'] == null
        ? null
        : User.fromJson(json['seller'] as Map<String, dynamic>),
    buyer: json['buyer'] == null
        ? null
        : User.fromJson(json['buyer'] as Map<String, dynamic>),
    post: json['post'] == null
        ? null
        : Post.fromJson(json['post'] as Map<String, dynamic>),
    messages: (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    recentMessage: json['recentMessage'] == null
        ? null
        : Message.fromJson(json['recentMessage'] as Map<String, dynamic>),
    buyerNonReadCount: json['buyerNonReadCount'] as int,
    sellerNonReadCount: json['sellerNonReadCount'] as int,
  );
}

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'seller': instance.seller,
      'buyer': instance.buyer,
      'post': instance.post,
      'messages': instance.messages,
      'recentMessage': instance.recentMessage,
      'buyerNonReadCount': instance.buyerNonReadCount,
      'sellerNonReadCount': instance.sellerNonReadCount,
    };

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message(
    userId: json['userId'] as int,
    text: json['text'] as String,
    createdAt: json['createdAt'] as String,
    showTime: json['showTime'] as bool,
    me: json['me'] as bool,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'userId': instance.userId,
      'text': instance.text,
      'createdAt': instance.createdAt,
      'showTime': instance.showTime,
      'me': instance.me,
    };
