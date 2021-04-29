
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/constants.dart';
class WallpaperController extends GetxController {

  WallpaperController get to => Get.find<WallpaperController>();


  void addToFav(Wallpaper wallpaper) {
    var list = Hive.box(FAV_BOX).get(FAV_LIST_KEY);

    if (!list.contains(wallpaper.id)) {
      list.add(wallpaper.id);
      Hive.box(FAV_BOX).put(FAV_LIST_KEY, list);
      print('Wallpaper Added to Favorites');
     /* Map<String,Object> map = new HashMap();
      map['wallpaperid'] = wallpaper.id;
      map['favorite'] = wallpaper.isFavorite.value;
      map['source'] = wallpaper.source;
      map['thumbnail'] = wallpaper.thumbnail;


      FirebaseFirestore.instance.collection('Users/Azzy/Favorites').doc(wallpaper.id).set(map);
*/
    }
  }

  void removeFromFav(Wallpaper wallpaper) {
    var list = Hive.box(FAV_BOX).get(FAV_LIST_KEY);

    if (list.remove(wallpaper.id)) {
      Hive.box(FAV_BOX).put(FAV_LIST_KEY, list);
      print('Wallpaper removed from Favorites');
    }
  }

  bool isFavorite(Wallpaper wallpaper) {
    return Hive.box(FAV_BOX).get(FAV_LIST_KEY).contains(wallpaper.id);
  }

}
