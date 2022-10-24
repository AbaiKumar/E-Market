// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market/Seller_Buyer_module/addproduct.dart';
import 'package:market/Seller_Buyer_module/driver.dart';
import 'package:market/Seller_Buyer_module/driver_order.dart';
import 'package:market/Seller_Buyer_module/elaborate.dart';
import 'package:market/Seller_Buyer_module/order.dart';
import 'package:market/Seller_Buyer_module/search.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/login_module/account.dart';
import 'package:market/model/sellerpost.dart';
import 'package:market/login_module/user_data_collect.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market/login_module/login_screen.dart';
import 'Seller_Buyer_module/common_home.dart';
import 'login_module/gifview.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future frontTime() async {
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await Future.delayed(const Duration(milliseconds: 3500));
  return;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => SellerPost(),
    child: MaterialApp(
      routes: {
        'userData': (context) => UserDataCollect(),
        'productsAdd': (context) => ProductsAdd("", {}),
        'OrderStatus': (context) => Order(),
        'searchPage': (context) => Search(""),
        'elboratePage': (context) => Elaborate("", false),
        'driverOrder': ((context) => DriverOrder()),
        "account": ((context) => SettingPage())
      },
      debugShowCheckedModeBanner: false,
      title: 'E-Market',
      home: FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color.fromRGBO(11, 10, 15, 1),
              child: GifView.asset(
                "assets/images/log1.gif",
                loop: false,
              ),
            );
          } else {
            return Theme(
              data: themeData,
              child: MyApp(),
            );
          }
        }),
        future: frontTime(),
      ),
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic auth;
  @override
  void initState() {
    super.initState();
    SellerPost.f = set;
    SellerPost.appRestart = set;
    auth = SellerPost.authentication;
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(event.notification!.title.toString()),
          content: Text(
            event.notification!.body.toString(),
            overflow: TextOverflow.visible,
            maxLines: 4,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("ok"),
            )
          ],
        ),
      );
      SellerPost.f();
    });
  }

  void set() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var a = Provider.of<SellerPost>(context, listen: false);
    return StreamBuilder(
        stream: auth.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return getWidg();
          }
          if (snapshot.hasData) {
            if (a.userEmail != null) {
              try {
                a.getSellerType(a.userEmail);
              } catch (e) {}
            }
            if (auth.currentUser!.emailVerified) {
              return UserTypeChanger();
            }
          }
          return LogScreen(set);
        });
  }
}

Widget getWidg() {
  return const SafeArea(
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );
}

class UserTypeChanger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var a = Provider.of<SellerPost>(context);
    switch (a.sellerType) {
      case "Seller":
      case "Buyer":
        return CommonHome();
      case "Driver":
        return Driver();
      case "Null":
        return UserDataCollect();
      default:
        return getWidg();
    }
  }
}
