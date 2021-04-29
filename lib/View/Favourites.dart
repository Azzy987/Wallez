import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallez_app/Controller/WallpaperController.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:get/get.dart';
import 'package:wallez_app/colors.dart';

class Favourites extends StatefulWidget {
  final List<Wallpaper> wallpaperList;

  Favourites({Key key, this.wallpaperList}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  WallpaperController wallpaperController = WallpaperController().to;

  @override
  Widget build(BuildContext context) {
    var wallpapers = widget.wallpaperList
        .where((wallpaper) => wallpaper.isFavorite.value)
        .toList().obs;
    return Material(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: GridView.builder(
            itemBuilder: (context, index) {
              String thumbnail =
                  wallpapers.elementAt(index).thumbnail;
              String imageUrl = wallpapers.elementAt(index).imageurl;
              String category =
                  wallpapers.elementAt(index).categoryName;
              String source = wallpapers.elementAt(index).source;

              //    String wallpostId = snapshot.data.docs.elementAt(index).docID;
              return GridTile(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => FullScreen(
                            wallpaperList: wallpapers,
                            initialWallpaper: index,
                          ), arguments: [
                            thumbnail,
                            category,
                            imageUrl,
                            source,
                          ]);
                        },
                        child: Hero(
                          tag: thumbnail,
                          transitionOnUserGestures: true,
                          child: CachedNetworkImage(
                            imageUrl: wallpapers.elementAt(index).thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, _) => Image.asset(
                              'assets/loading.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          color: Colors.black.withOpacity(0.7),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Obx(
                                    () =>
                                    IconButton(
                                      icon: wallpapers
                                          .elementAt(index)
                                          .isFavorite.value
                                          ? Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.redAccent,
                                      )
                                          : Icon(
                                        Icons.favorite_border_rounded,
                                        color: textColorDark,
                                      ),
                                      onPressed: () {
                                        wallpapers
                                            .elementAt(index)
                                            .isFavorite.value
                                            ? wallpaperController.removeFromFav(
                                            wallpapers.elementAt(
                                                index))
                                            : wallpaperController.addToFav(
                                            wallpapers.elementAt(
                                                index));
                                        wallpapers.elementAt(index).isFavorite.value =
                                        !wallpapers.elementAt(index).isFavorite.value;

                                      },
                                    ),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                      )
                    ],
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
              );
            },
            itemCount: wallpapers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
          )),
    );
  }
}
