import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/Category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velocity_x/velocity_x.dart';

class Categories extends StatefulWidget {
  final List<Wallpaper> wallpaperList;

  Categories({Key key, this.wallpaperList}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final categories = [];
  final categoryImages = [];


  @override
  void initState() {
    super.initState();
    widget.wallpaperList.forEach((wallpaper) {
      var category = wallpaper.categoryName;
      if (!categories.contains(category)) {
        categories.add(category);
        categoryImages.add(wallpaper.thumbnail);
      }
    });
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
        builder: (consumerContext, model, child){
      if (model.isOnline!=null){
        return model.isOnline ?
      GridView.builder(
            itemBuilder: (context, index) {
              String thumbnail = categoryImages.elementAt(index);
              //    String wallpostId = snapshot.data.docs.elementAt(index).docID;
              return GridTile(
                child: Container(
                  margin: EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                         MaterialPageRoute(
                           builder: (context){
                             return Category(
                               category: categories.elementAt(index),
                               thumbnail: categoryImages.elementAt(index),
                             );
                           }
                         ),
                         );

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
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          categories.elementAt(index).toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              decoration: TextDecoration.combine(
                                [
                                  TextDecoration.overline,
                                  TextDecoration.underline,
                                ],
                              ),
                              decorationStyle: TextDecorationStyle.double,
                              fontSize: 24,
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
                childAspectRatio: 1.9,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),

    ) : 'No internet connection'.text.xl4.makeCentered().shimmer();
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
