import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wallez_app/Controller/FavWallpaperController.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/View/Widgets/utilities.dart';

import '../colors.dart';

class FullScreen extends StatefulWidget {
  final thumbnail;
  final imageUrl;
  final source;
  final category;
  final wallpaperId;
  final index;
  final wallpaperList;

  FullScreen({
    Key key,
    @required this.thumbnail,
    @required this.imageUrl,
    @required this.source,
    @required this.category,
    @required this.wallpaperId,
    @required this.index,
    @required this.wallpaperList,
  }) : super(key: key);

  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  Directory directory;
  String imagePath;
  String checkImage;
  List<String> images = [];
  List<Color> colors;

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }

  /*PageController _pageController;
  int _currentIndex;*/

/*
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialWallpaper);
    _currentIndex = widget.initialWallpaper;
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
*/

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  Future<bool> saveWallpaper(String url, String fileName) async {
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();

          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/WallezApp";
          print(newPath);

          //  final file = await File(newPath).create(recursive: true);

          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        var list = directory.listSync();
        // print('List length ${list.length}');
        String check = widget.wallpaperId;
        for (int i = 0; i < list.length; i++) {
          if (list[i].toString().contains(check)) {
            print('Wallpaper Already Downloaded');
            return false;
          }
        }

        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        // print("Wallpaper not downloaded");

        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });
    bool downloaded =
        await saveWallpaper(widget.imageUrl, widget.wallpaperId + '.png');
    if (downloaded) {
      imagePath = directory.path + '/${widget.wallpaperId}.png';

      print("File Downloaded");
    } else {
      print("Wallpaper Alreadu Exists");
      imagePath = directory.path + '/${widget.wallpaperId}.png';

      return false;
    }

    setState(() {
      loading = false;
    });
    return true;
  }

  void _shareImage(BuildContext context, List<String> imagePath) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox;
    images = [];

    if (imagePath.isNotEmpty) {
      await Share.shareFiles(imagePath,
          text: 'Try This amazing app',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      print('Image not found');
    }
  }
  Future<void> colorsList() async{

}
  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline
              ? Scaffold(
                  body: Builder(
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          InteractiveViewer(
                            child: Container(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              child: Hero(
                                  transitionOnUserGestures: true,
                                  tag: widget.wallpaperId,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: widget.imageUrl,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).errorColor),
                                          value: downloadProgress.progress),
                                    ),
                                  )),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(16, 40, 0, 0),
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Vx.isAndroid
                                    ? Icon(Icons.arrow_back_rounded)
                                    : Icon(CupertinoIcons.back),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Vx.randomPrimaryColor,
                                  borderRadius: BorderRadius.circular(24)),
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.download_rounded),
                                      onPressed: () async {
                                        downloadFile();
                                      }),
                                  IconButton(
                                    onPressed: () async {
                                      if (await downloadFile()) {
                                        images.add(imagePath);
                                        _shareImage(context, images);
                                      } else {
                                        images.add(imagePath);
                                        _shareImage(context, images);
                                      }
                                    },
                                    icon: Icon(Icons.share_rounded),
                                  ),
                                  Consumer<WallpaperController>(
                                    builder: (context, data, child) {
                                      var favWallpaperManager =
                                          Provider.of<WallpaperController>(
                                              context,
                                              listen: false);
                                      return IconButton(
                                        icon: widget.wallpaperList
                                                .elementAt(widget.index)
                                                .isFavorite
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
                                              .elementAt(widget.index)
                                              .isFavorite) {
                                            favWallpaperManager.removeFromFav(
                                                widget.wallpaperList
                                                    .elementAt(widget.index),
                                                context);
                                          } else {
                                            favWallpaperManager.addToFav(
                                                widget.wallpaperList
                                                    .elementAt(widget.index),
                                                context);
                                          }
                                          widget.wallpaperList
                                                  .elementAt(widget.index)
                                                  .isFavorite =
                                              !widget.wallpaperList
                                                  .elementAt(widget.index)
                                                  .isFavorite;
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.format_paint_rounded),
                                      onPressed: () async {
                                        await setWallpaper(
                                            context: context,
                                            imgUrl: widget.imageUrl);
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : 'No internet connection'.marquee();
        }
        return Container(
            /*child: Center(
            child: CircularProgressIndicator(),
          ),*/
            );
      },
    );
  }
}
