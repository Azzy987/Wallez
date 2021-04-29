import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallez_app/Model/wallpaper.dart';
import 'package:wallez_app/View/Categories.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: 'Home'.text.makeCentered(),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Icon(Icons.home_rounded),
            Icon(Icons.dashboard_rounded),
            Icon(Icons.favorite_rounded),
          ],
        ),
      ),
      drawer: Drawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Wallez').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {

           var wallpaperList = List<Wallpaper>();
            snapshot.data.docs.forEach((documentSnapshot) {
              wallpaperList.add(Wallpaper.fromDcoumentSnapshot(documentSnapshot));
            });

            final _pages = [
              All_Images(
                wallpaperList: wallpaperList,
              ),
              Categories(
                wallpaperList: wallpaperList,
              ),
              Favourites(
                wallpaperList: wallpaperList,
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
    );
  }
}
