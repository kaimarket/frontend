import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:kaimarket/models/post.dart';

@immutable
abstract class UserEvent extends Equatable {
  UserEvent([List props = const []]);

  @override
  List<Object> get props => [];
}

class UserInit extends UserEvent {
  @override
  String toString() {
    return "Init";
  }
}

class UserDelete extends UserEvent {
  @override
  String toString() {
    return "Delete";
  }
}

class UserChangeWish extends UserEvent {
  final int postId;

  getPostId() => this.postId;

  UserChangeWish({this.postId});

  @override
  String toString() {
    return "UserChangeWish";
  }
}

class UserAddPurchase extends UserEvent {
  final Post item;

  getData() => this.item;

  UserAddPurchase({this.item});

  @override
  String toString() {
    return "AddPurchase";
  }
}

class UserGetWish extends UserEvent {
  @override
  String toString() {
    return "UserGetWish";
  }
}

class SearchWishInUser extends UserEvent {
  final bool wish;
  int postId;

  SearchWishInUser({this.postId, this.wish});

  @override
  String toString() {
    return "searchWish";
  }
}

class UserChangeProfile extends UserEvent {
  final String profilename;

  UserChangeProfile({this.profilename});

  @override
  String toString() {
    return "UserChangeProfile";
  }
}
