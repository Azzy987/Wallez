import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wallez_app/View/Widgets/utilities.dart';
import 'package:wallez_app/Model/wallpaper.dart';

/*class FullScreen extends StatefulWidget {
  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: Get.arguments[0].toString(),
              child: Image.network(
                Get.arguments[0].toString(),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 16, 16, 32),
                color: Colors.black.withOpacity(0.7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Get.arguments[1]),
                          Text(Get.arguments[3]),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Vx.isAndroid
                          ? Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.share_rounded),
                                      onPressed: () {}),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.favorite_border_rounded),
                                      onPressed: () {}),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.download_rounded),
                                      onPressed: () {}),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.format_paint_rounded),
                                      onPressed: () {
                                        setWallpaper(
                                            context: context,
                                            imgUrl: Get.arguments[0].toString());
                                      }),
                                )
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(CupertinoIcons.share),
                                    onPressed: () {},
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(CupertinoIcons.heart),
                                    onPressed: () {},
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(CupertinoIcons.download_circle),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}*/

class FullScreen extends StatefulWidget {
  final List<Wallpaper> wallpaperList;
  final int initialWallpaper;

  FullScreen(
      {Key key, @required this.wallpaperList, @required this.initialWallpaper})
      : super(key: key);

  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialWallpaper);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
              PhotoViewGallery.builder(
                  pageController: _pageController,
                  itemCount: widget.wallpaperList.length,
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      heroAttributes:
                      PhotoViewHeroAttributes(tag: Get.arguments[0]),
                      imageProvider: CachedNetworkImageProvider(
                          widget.wallpaperList
                              .elementAt(index)
                              .thumbnail),
                    );
                  }),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.download_rounded),
                        onPressed: () async {
                          var status = await Permission.storage.request();
                        }),
                    IconButton(
                        icon: Icon(Icons.format_paint_rounded),
                        onPressed: () async {
                          await setWallpaper(
                              context: context,
                              imgUrl: widget.wallpaperList
                                  .elementAt(_pageController.page.toInt())
                                  .thumbnail);
                        }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future _downloadWallpaper(BuildContext context) async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        var imageId = await ImageDownloader.downloadImage(
            widget.wallpaperList
                .elementAt(_pageController.page.toInt())
                .thumbnail,
            destination:
            AndroidDestinationType.directoryPictures);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wallpaper Downloaded'),
            action: SnackBarAction(
                label: 'Open',
                onPressed: () async {
                  var path =
                  await ImageDownloader.findPath(
                      imageId);
                  await ImageDownloader.open(path);
                }),
          ),
        );
      } catch (error) {
        print('Error $error');
      }
    } else {
      _showOpenSettingsAlert(context);
    }
  }

  void _showOpenSettingsAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return AlertDialog(
            title: Text('Need access to storage'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  openAppSettings();
                },
                child: Text('Open Settings'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(bc).pop();
                },
                child: Text('Cancel'),
              )
            ],
          );
        });
  }
}
