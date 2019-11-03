import 'package:json_annotation/json_annotation.dart';
import 'package:week_3/models/user.dart';
import 'package:week_3/models/post.dart';
import 'package:week_3/utils/utils.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  int id;
  User seller;
  User buyer;
  Post post;
  List<Message> messages;

  //최근 메시지
  Message recentMessage;
  int buyerNonReadCount;
  int sellerNonReadCount;

  Chat({
    this.id,
    this.seller,
    this.buyer,
    this.post,
    this.messages,
    this.recentMessage,
    this.buyerNonReadCount,
    this.sellerNonReadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}

@JsonSerializable()
class Message {
  int userId;
  String text;
  String createdAt;
  bool showTime;
  bool me;

  Message({this.userId, this.text, this.createdAt, this.showTime, this.me});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
