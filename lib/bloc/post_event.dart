import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:kaimarket/models/post.dart';

@immutable
abstract class PostEvent extends Equatable {
  PostEvent([List props = const []]);

  @override
  List<Object> get props => [];
}

class PostFetch extends PostEvent {
  final int selectedCategory;
  final String searchText;
  final bool reload; //모든 데이터 날리고 새로 로딩

  PostFetch(
      {this.selectedCategory = 0, this.searchText = '', this.reload = false});
  @override
  String toString() {
    return "Fetch";
  }
}

class PostInsert extends PostEvent {
  @override
  String toString() {
    return "Insert";
  }
}

class PostDelete extends PostEvent {
  final int postId;

  PostDelete({this.postId = 0});

  @override
  String toString() {
    return "Delete";
  }
}

class SearchWish extends PostEvent {
  final bool wish;
  int postId;

  SearchWish({this.postId, this.wish});

  @override
  String toString() {
    return "searchWish";
  }
}

class StatusUpdate extends PostEvent {
  int status;
  int postId;

  StatusUpdate({this.postId, this.status});

  @override
  String toString() {
    return "StatusUpdate";
  }
}
