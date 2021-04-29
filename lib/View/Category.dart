import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallez_app/Controller/WallpaperController.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:get/get.dart';
import 'package:wallez_app/colors.dart';

class Category extends StatefulWidget {
  final String category;

  const Category({Key key, this.category}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final WallpaperController wallpaperController = WallpaperController().to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  Get.arguments[1],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                background: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: Get.arguments[0].toString(),
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Wallez').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                var wallpapers =
                    _getWallpapersOfCurrentCategory(snapshot.data.docs);

                return GridView.builder(
                  itemBuilder: (context, index) {
                    String thumbnail = wallpapers.elementAt(index).thumbnail;
                    String imageUrl = wallpapers.elementAt(index).imageurl;
                    String source = wallpapers.elementAt(index).source;
                    String category = wallpapers.elementAt(index).categoryName;
                    return GridTile(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
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
                                Get.to(
                                    () => FullScreen(
                                          wallpaperList: wallpapers,
                                          initialWallpaper: index,
                                        ),
                                    arguments: [
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
                                  imageUrl: thumbnail,
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
                                      () => IconButton(
                                        icon: wallpapers
                                                .elementAt(index)
                                                .isFavorite
                                                .value
                                            ? Icon(
                                                Icons.favorite_rounded,
                                                color: Colors.redAccent,
                                              )
                                            : Icon(
                                                Icons.favorite_border_rounded,
                                                color: textColorDark,
                                              ),
                                        onPressed: () {
                                          if (wallpapers
                                              .elementAt(index)
                                              .isFavorite
                                              .value) {
                                            wallpaperController.removeFromFav(
                                                wallpapers.elementAt(index));
                                          } else {
                                            wallpaperController.addToFav(
                                                wallpapers.elementAt(index));
                                          }

                                          wallpapers
                                                  .elementAt(index)
                                                  .isFavorite
                                                  .value =
                                              !wallpapers
                                                  .elementAt(index)
                                                  .isFavorite
                                                  .value;
                                          print(wallpapers.elementAt(index).isFavorite.value);
                                        },
                                      ),
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                              ),
                            )
                          ],
                          clipBehavior: Clip.none,
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
                );
              }
              else{
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  List<Wallpaper> _getWallpapersOfCurrentCategory(
      List<DocumentSnapshot> documents) {
    var list = List<Wallpaper>();

    documents.forEach((document) {
      var wallpaper = Wallpaper.fromDcoumentSnapshot(document);

      if (wallpaper.categoryName == widget.category) {
        if (wallpaperController.isFavorite(wallpaper)) {
          wallpaper.isFavorite.value = true;
        }

        list.add(wallpaper);
      }
    });

    return list;
  }
}
