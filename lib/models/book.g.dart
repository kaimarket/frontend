// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book(
    title: json['title'] as String,
    link: json['link'] as String,
    image: json['image'] as String,
    author: json['author'] as String,
    price: json['price'] as int,
    discount: json['discount'] as int,
    pubdate: json['pubdate'] as String,
    publisher: json['publisher'] as String,
    isbn: json['isbn'] as String,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'image': instance.image,
      'author': instance.author,
      'price': instance.price,
      'discount': instance.discount,
      'publisher': instance.publisher,
      'pubdate': instance.pubdate,
      'isbn': instance.isbn,
      'description': instance.description,
    };
