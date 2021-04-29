import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Wallpaper extends GetxController{
  final String thumbnail;
  final String categoryName;
  final String imageurl;
  final String source;
  final String id;
  final isFavorite;

  Wallpaper.fromDcoumentSnapshot(DocumentSnapshot snapshot)
      : this.thumbnail = snapshot['thumbnail'],
        this.categoryName = snapshot['categoryName'],
        this.imageurl = snapshot['image_url'],
        this.source = snapshot['source'],
        this.id = snapshot.id,
        this.isFavorite = false.obs;
}
