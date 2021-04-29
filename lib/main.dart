import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallez_app/Controller/Theme/AppTheme.dart';
import 'package:wallez_app/Controller/Theme/ThemeService.dart';
import 'package:wallez_app/Controller/WallpaperController.dart';
import 'package:wallez_app/View/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallez_app/constants.dart';

// void main() {
//   runApp(MyApp());
// }

Future<void> main() async {
  await initApp();
  runApp(
    WallpaperApp(),
  );
}

Future initApp() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init(); //Make sure you imported firebase_core
  var docDir = await getApplicationDocumentsDirectory();
  Hive.init(docDir.path);
  Get.put(WallpaperController());
  
  var favBox = await Hive.openBox(FAV_BOX);
  if (favBox.get(FAV_LIST_KEY) == null){
    favBox.put(FAV_LIST_KEY, List<dynamic>());
  }
}

class WallpaperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().lightTheme,
      darkTheme: AppTheme().darkTheme,
      themeMode: ThemeService().getThemeMode(),
      home: HomePage(),
    );
  }
}

// class MyHomePage extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           Switch(
//             onChanged: (value){
//              ThemeService().changeThemeMode();
//             },
//             value: ThemeService().isSavedDarkMode(),

//           )
//         ],
//       ),
//        body: MaterialButton(
//          onPressed: (){
//            ThemeService().changeThemeMode();

//          },
//          child: "Switch Theme".text.makeCentered(),
//        )
//     );
//   }
// }
