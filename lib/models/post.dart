import 'package:flutter/material.dart';
import 'package:week_3/models/category.dart';
import 'package:week_3/models/book.dart';
import 'package:week_3/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:week_3/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post extends Equatable {
  int id;
  String title;
  String content;
  int price;
  int view;
  int wish;
  int chat;
  String createdAt;
  String updatedAt;
  bool isWish;
  bool isSold;
  int status;
  // status 0: 판매중, 1: 예약중, 2: 판매완료

  List<Map<String, dynamic>> images = [];
  User user;
  double locationLat;
  double locationLng;

  @JsonKey(name: 'categoryId', fromJson: _parseCategory)
  Category category;

  //도서 변수
  bool isBook;
  String bookMajor;
  String bookAuthor;
  String bookPublisher;
  String bookPubDate;
  String bookImage;
  int bookPrice;

  Post({
    this.id,
    this.title,
    this.content,
    this.price = 0,
    this.view = 0,
    this.wish = 0,
    this.chat = 0,
    this.createdAt,
    this.updatedAt,
    this.isWish,
    this.isSold,
    this.status,

    //
    this.images,
    this.user,
    this.locationLat,
    this.locationLng,
    this.category,

    //도서 변수
    this.isBook = false,
    this.bookMajor,
    this.bookAuthor,
    this.bookPublisher,
    this.bookPubDate,
    this.bookPrice = 0,
    this.bookImage,
  });

  @override
  List<Object> get props => [
        id,
        title,
        content,
        price,
        view,
        wish,
        chat,
        createdAt,
        updatedAt,
        isWish,
        isSold,
        status,
        images,
        user,
        locationLat,
        locationLng,
        category,
        isBook,
        bookMajor,
        bookAuthor,
        bookPublisher,
        bookPubDate,
        bookPrice,
        bookImage,
      ];

  @override
  String toString() => 'Post { _id: $title }';

  Post copyWith({
    int id,
    String title,
    String content,
    int price,
    int view,
    int wish,
    int chat,
    String createdAt,
    String updatedAt,
    bool isWish,
    bool isSold,
    int status,
    List<Map<String, dynamic>> images,
    User user,
    double locationLat,
    double locationLng,
    Category category,
    bool isBook,
    String bookMajor,
    String bookAuthor,
    String bookPublisher,
    String bookPubDate,
    String bookImage,
    int bookPrice,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      price: price ?? this.price,
      view: view ?? this.view,
      wish: wish ?? this.wish,
      chat: chat ?? this.chat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isWish: isWish ?? this.isWish,
      isSold: isSold ?? this.isSold,
      status: status ?? this.status,
      images: images ?? this.images,
      user: user ?? this.user,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      category: category ?? this.category,
      isBook: isBook ?? this.isBook,
      bookMajor: bookMajor ?? this.bookMajor,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookPublisher: bookPublisher ?? this.bookPublisher,
      bookPubDate: bookPubDate ?? this.bookPubDate,
      bookImage: bookImage ?? this.bookImage,
      bookPrice: bookPrice ?? this.bookPrice,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  //책으로부터 정보 받아오기
  Post.fromBook(Book book)
      : title = book.title,
        bookAuthor = book.author,
        bookPublisher = book.publisher,
        bookPubDate = book.pubdate,
        bookPrice = book.price,
        bookImage = book.image,
        isBook = true,
        category = CategoryList[7];

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

Category _parseCategory(int categoryId) {
  return CategoryList[categoryId];
}
