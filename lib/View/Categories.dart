import 'package:flutter/material.dart';
import 'package:wallez_app/Controller/WallpaperController.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/Category.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Categories extends StatefulWidget {
  final List<Wallpaper> wallpaperList;

  Categories({Key key, this.wallpaperList}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final wallpaperController = WallpaperController().to;
  final categories = [];
  final categoryImages = [];

  @override
  void initState() {
    super.initState();
    widget.wallpaperList.forEach((wallpaper) {
      var category = wallpaper.categoryName;
      if (!categories.contains(category)){
        categories.add(category);
        categoryImages.add(wallpaper.thumbnail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: GridView.builder(
            itemBuilder: (context, index) {
              String thumbnail = categoryImages.elementAt(index);
              //    String wallpostId = snapshot.data.docs.elementAt(index).docID;
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
                          Get.to(() => Category(
                            category: categories.elementAt(index),
                          ), arguments: [
                            thumbnail,
                            categories.elementAt(index),
                          ]);
                        },
                        child: Hero(
                          tag: thumbnail,
                          transitionOnUserGestures: true,
                          child: CachedNetworkImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, _) =>
                                Image.asset('assets/loading.png', fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          categories.elementAt(index).toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: TextDecoration.combine([
                              TextDecoration.overline,
                              TextDecoration.underline,
                            ]),
                              decorationStyle: TextDecorationStyle.double,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                    clipBehavior: Clip.none,
                  ),
                ),
              );
            },
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.0,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
          )),
    );
  }
}
