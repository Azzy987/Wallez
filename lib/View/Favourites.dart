import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallez_app/Controller/FavWallpaperController.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:get/get.dart';
import 'package:wallez_app/colors.dart';
import 'package:velocity_x/velocity_x.dart';

class Favourites extends StatefulWidget {
  final List<Wallpaper> wallpaperList;

  Favourites({Key key, this.wallpaperList}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    var wallpapers = widget.wallpaperList
        .where((wallpaper) => wallpaper.isFavorite)
        .toList();

    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline
              ? Material(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: wallpapers.length > 0
                          ? GridView.builder(
                              itemBuilder: (context, index) {
                                var favWallpaperManager =
                                    Provider.of<WallpaperController>(context,
                                        listen: false);
                                String thumbnail =
                                    wallpapers.elementAt(index).thumbnail;
                                String imageUrl =
                                    wallpapers.elementAt(index).imageurl;
                                String category =
                                    wallpapers.elementAt(index).categoryName;
                                String source =
                                    wallpapers.elementAt(index).source;
                                String wallpaperId =
                                    wallpapers.elementAt(index).id;
                                /*  String thumbnail =
                    wallpaperController.favWallpapers[index].thumbnail;
                String imageUrl =
                    wallpaperController.favWallpapers[index].imageurl;
                String category =
                    wallpaperController.favWallpapers[index].categoryName;
                String source = wallpaperController.favWallpapers[index].source;
                String wallpaperId =
                    wallpaperController.favWallpapers[index].id;*/
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
                                            Get.to(
                                              () => FullScreen(
                                                thumbnail: thumbnail,
                                                imageUrl: imageUrl,
                                                source: source,
                                                category: category,
                                                wallpaperId: wallpaperId,
                                                wallpaperList: wallpapers,
                                                index: index,
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: wallpaperId,
                                            transitionOnUserGestures: true,
                                            child: CachedNetworkImage(
                                              imageUrl: thumbnail,
                                              fit: BoxFit.cover,
                                              placeholder: (context, _) =>
                                                  Image.asset(
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
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    category.toUpperCase(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: wallpapers
                                                          .elementAt(index)
                                                          .isFavorite
                                                      ? Icon(
                                                          Icons
                                                              .favorite_rounded,
                                                          color:
                                                              Colors.redAccent,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .favorite_border_rounded,
                                                          color: textColorDark,
                                                        ),
                                                  onPressed: () {
                                                    if (wallpapers
                                                        .elementAt(index)
                                                        .isFavorite) {
                                                      favWallpaperManager
                                                          .removeFromFav(
                                                              wallpapers
                                                                  .elementAt(
                                                                      index),
                                                              context);
                                                    } else {
                                                      favWallpaperManager
                                                          .addToFav(
                                                              wallpapers
                                                                  .elementAt(
                                                                      index),
                                                              context);
                                                    }
                                                    wallpapers
                                                            .elementAt(index)
                                                            .isFavorite =
                                                        !wallpapers
                                                            .elementAt(index)
                                                            .isFavorite;
                                                  },
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.7,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8),
                            )
                          : "No favourite Wallpapers"
                              .text
                              .xl3
                              .makeCentered()
                              .shimmer()),
                )
              : 'No internet connection'.marquee();
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
