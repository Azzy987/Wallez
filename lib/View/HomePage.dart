import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:wallez_app/Controller/FavWallpaperController.dart';
import 'package:wallez_app/Controller/connectivity_provider.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/Categories.dart';
import 'package:wallez_app/View/Demo.dart';
import 'package:wallez_app/View/Favourites.dart';
import 'package:wallez_app/View/All_Images.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;

  HomePage({Key key, this.snapshot}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConnectivityProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: 'Wallez'.text.make().shimmer(),
          centerTitle: true,
          bottom: TabBar(
            labelPadding: EdgeInsets.all(8),
            indicatorWeight: 3,
            controller: _tabController,
            tabs: [
              Icon(Icons.home_rounded),
              Icon(Icons.dashboard_rounded),
              Icon(Icons.favorite_rounded),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: searchWallpapers());
              },
              icon: Icon(Icons.search_rounded),
            ),
          ],
        ),
        drawer: Drawer(
          child: Material(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: 200,
                  width: context.screenWidth,
                  decoration: BoxDecoration(
                      color: Colors.purple,
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://images.unsplash.com/photo-1597773150796-e5c14ebecbf5?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1500&q=80'),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 16,
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Favorites'),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Friends'),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Request'),
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () => Get.to(
                          () => Demo(
                            index: 5,
                          ),
                        )),
              ],
            ),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Wallez')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
              List wallpapersList = List<Wallpaper>.empty(growable: true);

              snapshot.data.docs.forEach((documentSnapshot) {
                var wallpaper =
                    Wallpaper.fromDcoumentSnapshot(documentSnapshot);
                var favWallpaperManager =
                    Provider.of<WallpaperController>(context);

                if (favWallpaperManager.isFavorite(wallpaper)) {
                  wallpaper.isFavorite = true;
                }
                wallpapersList.add(wallpaper);
                //  print('data');
              });

              var _pages = [
                All_Images(
                  wallpaperList: wallpapersList,
                ),
                Categories(
                  wallpaperList: wallpapersList,
                ),
                Favourites(
                  wallpaperList: wallpapersList,
                ),
              ];
              return TabBarView(
                controller: _tabController,
                children: _pages,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class searchWallpapers extends SearchDelegate {
  final wallpapersData = [
    "Jaipur",
    "Agra",
    "Chennai",
    "Hyderabad",
    "Kanpur",
    "Bombay",
    "Udaipur",
    "Patna",
  ];
  final currentWallpapers = [
    "Hyderabad",
    "Kanpur",
    "Bombay",
    "Udaipur",
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? currentWallpapers
        : wallpapersData.where((name) => name.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Get.to(() => Demo(
                index: index,
              ));
        },
        leading: Icon(Icons.location_city),
        title: Text(
          suggestionsList[index],
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
