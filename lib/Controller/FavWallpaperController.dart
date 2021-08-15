import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/colors.dart';
import 'package:wallez_app/constants.dart';

class WallpaperController extends ChangeNotifier {
 // WallpaperController get to => Get.find<WallpaperController>();
  //final _getStorageVar = GetStorage();
 // final storageKey = FAV_LIST;
 // var favWallpapers = List<Wallpaper>().obs;





  void addToFav(Wallpaper wallpaper, BuildContext context) {
    var list = GetStorage().read(FAV_LIST_KEY);

    if (!list.contains(wallpaper.id)) {
      list.add(wallpaper.id);
     GetStorage().write(FAV_LIST_KEY, list);
     showToast(context, 'Wallpaper added to Favorites');
      notifyListeners();
    }
  }

  void removeFromFav(Wallpaper wallpaper, BuildContext context) {
    var list = GetStorage().read(FAV_LIST_KEY);

    if (list.remove(wallpaper.id)) {
      GetStorage().write(FAV_LIST_KEY, list);
      showToast(context, 'Wallpaper removed from Favorites');
      notifyListeners();
    }
  }

  bool isFavorite(Wallpaper wallpaper) {
    return GetStorage().read(FAV_LIST_KEY).contains(wallpaper.id);
  }
}
void showToast(BuildContext context, String message){
  VxToast.show(context, msg: message, bgColor: Vx.randomPrimaryColor, textColor: textColorDark);
}

  /*void addToFav(Wallpaper wallpaper) {
    var list = Hive.box(FAV_BOX).get(FAV_LIST_KEY);

    if (!list.contains(wallpaper.id)) {
      list.add(wallpaper.id);
      Hive.box(FAV_BOX).put(FAV_LIST_KEY, list);
      print('Wallpaper Added to Favorites');
      *//* Map<String,Object> map = new HashMap();
      map['wallpaperid'] = wallpaper.id;
      map['favorite'] = wallpaper.isFavorite.value;
      map['source'] = wallpaper.source;
      map['thumbnail'] = wallpaper.thumbnail;


      FirebaseFirestore.instance.collection('Users/Azzy/Favorites').doc(wallpaper.id).set(map);
 *//*
    }
  }
*/
 /* @override
  void onInit() {
    var favList = List<dynamic>.empty(growable: true);

    _getStorageVar.writeIfNull(FAV_LIST_KEY, favList);

    List storedWallpaers = GetStorage().read<List>(FAV_LIST_KEY_NEW);
    if (!storedWallpaers.isNull) {
      favWallpapers = storedWallpaers.map((e) => Wallpaper.fromJson(e)).toList().obs;
    }
    ever(favWallpapers, (_) {
      GetStorage().write(FAV_LIST_KEY_NEW, favWallpapers.toList());
    });

    super.onInit();

*//*
    if (isFirstTimeRun() == false){
      _getStorageVar.write(FAV_LIST_KEY , favList);
      firstTime = true;
      _getStorageVar.write(firstTimeRun, true);
      print('First time run');
    }
*//*

  }
*/
  /*void addtofavGet(Wallpaper wallpaper) {
    var favList = _getStorageVar.read(FAV_LIST_KEY);

    if (!favList.contains(wallpaper.id)) {
      favList.add(wallpaper.id);
      _getStorageVar.write(FAV_LIST_KEY, favList);
      print('Wallpaper Added to Favorites from Get Storage');
      Get.snackbar('Wallpaper added to Favorites', '');
    }
  }

  void removeFromFavGet(Wallpaper wallpaper) {
    final favList = _getStorageVar.read(FAV_LIST_KEY);
    if (favList.remove(wallpaper.id)) {
      _getStorageVar.write(FAV_LIST_KEY, favList);
      print('Wallpaper removed from Favorites from Get Storage');
      Get.snackbar('Wallpaper removed from Favorites', '');

    }
  }*/
  /*bool isFavGet(Wallpaper wallpaper) {
    return favWallpapers.contains(wallpaper.id) ?? false;

  }*/
  /*bool isFirstTimeRun() {
    return _getStorageVar.read(firstTimeRun) ?? false;
  }*/

 /*void removeFromFav(Wallpaper wallpaper) {
    final list = Hive.box(FAV_BOX).get(FAV_LIST_KEY);

    if (list.remove(wallpaper.id)) {
      Hive.box(FAV_BOX).put(FAV_LIST_KEY, list);
      print('Wallpaper removed from Favorites');
    }
  }

  bool isFavorite(Wallpaper wallpaper) {
    return Hive.box(FAV_BOX).get(FAV_LIST_KEY).contains(wallpaper.id);
  }*/

