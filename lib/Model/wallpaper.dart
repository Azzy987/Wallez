import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Wallpaper {
  final String thumbnail;
  final String categoryName;
  final String imageurl;
  final String source;
  final String id;
  bool isFavorite;

  Wallpaper({
    @required this.thumbnail,
    @required this.categoryName,
    @required this.imageurl,
    @required this.source,
    @required this.id,
    this.isFavorite,
  });

  Wallpaper.fromDcoumentSnapshot(DocumentSnapshot snapshot)
      : this.thumbnail = snapshot['thumbnail'],
        this.categoryName = snapshot['categoryName'],
        this.imageurl = snapshot['image_url'],
        this.source = snapshot['source'],
        this.id = snapshot.id,
        this.isFavorite = false;
}
