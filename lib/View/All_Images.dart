import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wallez_app/Controller/FavWallpaperController.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/FullScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallez_app/colors.dart';

class All_Images extends StatefulWidget {
  List<Wallpaper> wallpaperList;

  All_Images({Key key, this.wallpaperList}) : super(key: key);

  @override
  _All_ImagesState createState() => _All_ImagesState();
}

class _All_ImagesState extends State<All_Images> {
  List<DocumentSnapshot> wallList = []; // stores fetched wallpapers

  bool isLoading = false; // track if products fetching

  bool hasMore = true; // flag for more products available or not

  int documentLimit = 10; // documents to be fetched per request

  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched

  ScrollController _scrollController = ScrollController();

  //final wallpaperController = WallpaperController().to;

/*  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }*/

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
      querySnapshot = await FirebaseFirestore.instance
          .collection('Wallez')
          .orderBy('timestamp', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('Wallez')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
      print(1);
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
    //FirebaseFirestore firestore = FirebaseFirestore.instance;
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        if (model.isOnline != null) {
          return model.isOnline
              ? Scaffold(
                  body: ListView(
                    controller: _scrollController,
                    children: [
                      SizedBox(
                        height: 200,
                        width: context.width,
                        child:
                            VxSwiper.builder(
                          itemCount: widget.wallpaperList.length,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,

                          scrollDirection: Axis.horizontal,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 4),
                          itemBuilder: (context, index) {
                            String thumbnail =
                                widget.wallpaperList.elementAt(index).thumbnail;
                            String imageUrl =
                                widget.wallpaperList.elementAt(index).imageurl;
                            String category = widget.wallpaperList
                                .elementAt(index)
                                .categoryName;
                            String source =
                                widget.wallpaperList.elementAt(index).source;
                            String wallpaperId =
                                widget.wallpaperList.elementAt(index).id;
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => FullScreen(
                                    thumbnail: thumbnail,
                                    imageUrl: imageUrl,
                                    source: source,
                                    category: category,
                                    wallpaperId: wallpaperId,
                                    wallpaperList: widget.wallpaperList,
                                    index: index,
                                  ),
                                );
                              },
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                margin: EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                                child: CachedNetworkImage(
                                  imageUrl: thumbnail,
                                  fit: BoxFit.cover,
                                  placeholder: (context, _) => Image.asset(
                                    'assets/loading.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: wallList.length == 0
                              ? Center(
                                  child: Text('Loading...'),
                                )
                              : GridView.builder(
                                  // controller: _scrollController,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    String thumbnail = wallList
                                        .elementAt(index)
                                        .data()['thumbnail'];
                                    String imageUrl = wallList
                                        .elementAt(index)
                                        .data()['imageurl'];
                                    String category = wallList
                                        .elementAt(index)
                                        .data()['categoryName'];
                                    String source = wallList
                                        .elementAt(index)
                                        .data()['source'];
                                    String wallpaperId =
                                        wallList.elementAt(index).id;

                                    //print('Length is ${wallList.length}');

                                    var favWallpaperManager =
                                        Provider.of<WallpaperController>(
                                            context,
                                            listen: false);

                                    if (index % 10 == 0 && index > 1) {
                                      return Container(
                                        height: 10,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                          child:
                                              "This is an ad".text.xl4.make(),
                                        ),
                                      );
                                    } else {
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
                                                      thumbnail: widget
                                                          .wallpaperList
                                                          .elementAt(index)
                                                          .thumbnail,
                                                      imageUrl: widget
                                                          .wallpaperList
                                                          .elementAt(index)
                                                          .imageurl,
                                                      source: widget
                                                          .wallpaperList
                                                          .elementAt(index)
                                                          .source,
                                                      category: widget
                                                          .wallpaperList
                                                          .elementAt(index)
                                                          .categoryName,
                                                      wallpaperId: widget
                                                          .wallpaperList
                                                          .elementAt(index)
                                                          .id,
                                                      wallpaperList:
                                                          widget.wallpaperList,
                                                      index: index,
                                                    ),
                                                  );
                                                },
                                                child: Hero(
                                                  tag: wallpaperId,
                                                  transitionOnUserGestures:
                                                      true,
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
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          category
                                                              .toUpperCase(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: widget
                                                                .wallpaperList
                                                                .elementAt(
                                                                    index)
                                                                .isFavorite
                                                            ? Icon(
                                                                Icons
                                                                    .favorite_rounded,
                                                                color: Colors
                                                                    .redAccent,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .favorite_border_rounded,
                                                                color:
                                                                    textColorDark,
                                                              ),
                                                        onPressed: () {
                                                          if (widget
                                                              .wallpaperList
                                                              .elementAt(index)
                                                              .isFavorite) {
                                                            favWallpaperManager
                                                                .removeFromFav(
                                                                    widget
                                                                        .wallpaperList
                                                                        .elementAt(
                                                                            index),
                                                                    context);
                                                          } else {
                                                            favWallpaperManager.addToFav(
                                                                widget
                                                                    .wallpaperList
                                                                    .elementAt(
                                                                        index),
                                                                context);
                                                          }
                                                          widget.wallpaperList
                                                                  .elementAt(index)
                                                                  .isFavorite =
                                                              !widget
                                                                  .wallpaperList
                                                                  .elementAt(
                                                                      index)
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
                                            clipBehavior: Clip.none,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  itemCount: wallList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.7,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8),
                                ),
                        ),
                      ),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                    ],
                  ),
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
