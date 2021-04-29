import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallez_app/Controller/WallpaperController.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:wallez_app/colors.dart';

class All_Images extends StatefulWidget {
   List<Wallpaper> wallpaperList;

  All_Images({Key key, this.wallpaperList}) : super(key: key);

  @override
  _All_ImagesState createState() => _All_ImagesState();
}

class _All_ImagesState extends State<All_Images> {
  final wallpaperController = WallpaperController().to;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: GridView.builder(
            itemBuilder: (context, index) {
              String thumbnail =
                  widget.wallpaperList.elementAt(index).thumbnail;
              String imageUrl = widget.wallpaperList.elementAt(index).imageurl;
              String category =
                  widget.wallpaperList.elementAt(index).categoryName;
              String source = widget.wallpaperList.elementAt(index).source;
              String wallpostId = widget.wallpaperList.elementAt(index).id;

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
                          Get.to(
                              () => FullScreen(
                                    wallpaperList: widget.wallpaperList,
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
                                  icon: widget.wallpaperList
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
                                    if (widget.wallpaperList
                                        .elementAt(index)
                                        .isFavorite
                                        .value) {
                                      wallpaperController.removeFromFav(
                                          widget.wallpaperList.elementAt(index));
                                    } else {
                                      wallpaperController.addToFav(
                                          widget.wallpaperList.elementAt(index));
                                    }

                                    widget.wallpaperList
                                        .elementAt(index)
                                        .isFavorite
                                        .value =
                                    !widget.wallpaperList
                                        .elementAt(index)
                                        .isFavorite
                                        .value;
                                    print(widget.wallpaperList.elementAt(index).isFavorite.value);
                                  },
                                ),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                      )
                    ],
                    clipBehavior: Clip.none,
                  ),
                ),
              );
            },
            itemCount: widget.wallpaperList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
          )),
    );
  }
}
