import 'package:flutter/material.dart';
import 'package:kaimarket/models/post.dart';
import 'package:kaimarket/models/chat.dart';
import 'package:kaimarket/utils/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

//   purchases: [{ type: Schema.Types.ObjectId, ref: "post" }], //구매내역
//   sales: [{ type: Schema.Types.ObjectId, ref: "post" }], //판매내역
//   chats: [{ type: Schema.Types.ObjectId, ref: "chat" }],
//   wish: [{ type: Schema.Types.ObjectId, ref: "post" }],
//   keywords: [String]

// User class가 생성된 파일의 private 멤버에 접근하는 것을 허용.
// *.g.dart
part 'user.g.dart';

// 클래스가 시리얼라이즈가 필요하다고 알림.
@JsonSerializable()
class User extends Equatable {
  int id;
  String name;
  String email;
  List<Post> purchases;
  List<Post> sales;
  List<Post> wish;
  List<String> keywords;
  List<Chat> chats;
  int salesCount = 0;

  User({
    this.id,
    this.name,
    this.email,
    this.purchases,
    this.sales,
    this.wish,
    this.keywords,
    this.chats,
    this.salesCount,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User.copyWith(User p) {
    id = p.id;
    name = p.name;
    email = p.email;
    purchases = p.purchases;
    sales = p.sales;
    wish = p.wish;
    keywords = p.keywords;
    chats = p.chats;
    salesCount = p.salesCount;
  }

  @override
  List<Object> get props =>
      [id, name, email, purchases, sales, wish, keywords, chats, salesCount];

  // @override
  // bool operator ==(Object other) {
  //     Function deepEq = const DeepCollectionEquality().equals;
  //     return identical(this, other) ||
  //     other is User &&
  //         runtimeType == other.runtimeType &&
  //         name == other.name &&
  //         id == other.id &&
  //         deepEq(wish,other.wish);
  // }
}
