import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wallez_app/Controller/FavWallpaperController.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:get/get.dart';
import 'package:wallez_app/colors.dart';

class Category extends StatefulWidget {
  final String category;
  final String thumbnail;

  const Category({Key key, this.category, this.thumbnail}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<DocumentSnapshot> wallList = []; // stores fetched wallpapers

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false; // track if products fetching

  bool hasMore = true; // flag for more products available or not

  int documentLimit = 10; // documents to be fetched per request

  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched

  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    getProducts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.60;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
  }

  getProducts() async {
    if (!hasMore) {
      print('No More Wallpapers');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('Wallez')
          .where('categoryName', isEqualTo: widget.category)
          // .orderBy('timestamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await firestore
          .collection('Wallez')
          .where('categoryName', isEqualTo: widget.category)
          // .orderBy('timestamp', descending: true)
          // .where('categoryName', isEqualTo: widget.category)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
     // print(1);
    }
    if (querySnapshot.size < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    wallList.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline
              ? Scaffold(
                  appBar: AppBar(
                    title: widget.category.text.make(),
                  ),
                  body: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Wallez')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // Get all wallpapers of widget.category.
                        var wallpapers =
                            _getWallpapersOfCurrentCategory(snapshot.data.docs);

                        return Container(
                          margin: EdgeInsets.all(8),
                          child: GridView.builder(
                            controller: _scrollController,
                            itemCount: wallList.length,
                            itemBuilder: (BuildContext context, int index) {
                              var favWallpaperManager =
                                  Provider.of<WallpaperController>(context,
                                      listen: false);
                              String thumbnail =
                                  wallList.elementAt(index).data()['thumbnail'];
                              String imageUrl =
                                  wallList.elementAt(index).data()['imageurl'];
                              String category = wallList
                                  .elementAt(index)
                                  .data()['categoryName'];
                              String source =
                                  wallList.elementAt(index).data()['source'];
                              String wallpaperId = wallList.elementAt(index).id;

                              return GridTile(
                                child: InkResponse(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FullScreen(
                                          thumbnail: wallpapers
                                              .elementAt(index)
                                              .thumbnail,
                                          imageUrl: wallpapers
                                              .elementAt(index)
                                              .imageurl,
                                          source: source,
                                          category: category,
                                          wallpaperId: wallpaperId,
                                          wallpaperList: wallpapers,
                                          index: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: wallpaperId,
                                    transitionOnUserGestures: true,
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              thumbnail),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 8),
                                          color: Colors.black.withOpacity(0.7),
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
                                                        Icons.favorite_rounded,
                                                        color: Colors.redAccent,
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
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.7,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              : 'No internet connection'.text.xl4.makeCentered().shimmer();
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  List<Wallpaper> _getWallpapersOfCurrentCategory(
      List<DocumentSnapshot> documents) {
    var list = List<Wallpaper>.empty(growable: true);

    documents.forEach((document) {
      var wallpaper = Wallpaper.fromDcoumentSnapshot(document);
      var favWallpaperManager =
          Provider.of<WallpaperController>(context, listen: false);
      if (wallpaper.categoryName == widget.category) {
        if (favWallpaperManager.isFavorite(wallpaper)) {
          wallpaper.isFavorite = true;
        }

        list.add(wallpaper);
      }
    });
    //  wallList.forEach((element) { })

    return list;
  }
}
