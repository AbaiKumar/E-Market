import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class SellerPost with ChangeNotifier {
  static late Function appRestart;
  static late dynamic f;
  static final authentication = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  late String userID = "";
  String? userEmail;
  bool dataContainInMysql = true;
  late String sellerType = "loading";
  List<Map> sellerList = [];
  Set myProdBuy = {};
  List<Map> myProdSel = [];
  var myDriver = [];

  SellerPost() {
    updater();
  }
  Future<List> getData(String uid) async {
    try {
      String url =
          "https://abai-194101.000webhostapp.com/sellerData.php?uid=$uid";
      var res = await http.get(Uri.parse(url));
      return res.body.split('-');
    } catch (e) {}
    return [];
  }

  Future delAfterDelivery(data) async {
    String drtoken = "", seltoken = "";
    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/orders")
        .get();
    for (var val in path1.docs) {
      if (val.data()['prod_id'] == data['id']) {
        var tmp =
            await firestore.collection("seller").doc(data['selleruid']).get();
        seltoken = tmp.data()!['msgtoken'];
        await val.reference.delete();
        break;
      }
    }
    var path2 = await firestore.collection("buyer/" + userID + "/orders").get();
    for (var val in path2.docs) {
      if (val.data()['prod_id'] == data['id']) {
        await val.reference.delete();
        break;
      }
    }
    var path3 =
        await firestore.collection("buyer/" + userID + "/transport").get();
    for (var val in path3.docs) {
      if (val.data()['id'] == data['id']) {
        await val.reference.delete();
        break;
      }
    }
    var path4 = await firestore.collection("driver/").get();
    for (var val in path4.docs) {
      var path5 = await val.reference.collection("work").get();
      for (var j in path5.docs) {
        if (j.data()['prod_id'] == data['id']) {
          await j.reference.delete();
          drtoken = val.data()['msgtoken'];
          break;
        }
      }
    }
    driverMsg(data, "Delivery", seltoken);
    driverMsg(data, "Delivery", drtoken);
  }

  void updater() {
    if (authentication.currentUser != null) {
      userID = authentication.currentUser!.uid;
      userEmail = authentication.currentUser!.email;
      isDataContainInMysql(false, sellerType);
    }
  }

  Future updateCancel(data) async {
    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/products")
        .get();
    for (var val in path1.docs) {
      if (val.data()['id'] == data['id']) {
        int value =
            int.parse(val.data()['stock']) + int.parse(data['quantity']);
        await val.reference.update({"stock": value.toString()});
        break;
      }
    }
  }

  void getSellerType(String? mail) async {
    try {
      String url =
          "https://abai-194101.000webhostapp.com/user_type.php?email=$mail";
      var res = await http.get(Uri.parse(url));
      sellerType = res.body.isEmpty ? "Null" : res.body;
      await updateToken();
    } catch (e) {}
    notifyListeners();
  }

  Future<bool> cancelProduct(data, reason) async {
    dynamic buyerid;
    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/orders")
        .get();
    for (var val in path1.docs) {
      if (val.data()['prod_id'] == data['id']) {
        buyerid = val.data()['buyer_id'];
        await val.reference.delete();
        break;
      }
    }
    var path2 =
        await firestore.collection("buyer/" + buyerid + "/orders").get();
    for (var val in path2.docs) {
      if (!val.exists) {
        return false;
      }
      if (val.data()['prod_id'] == data['id']) {
        await val.reference.delete();
        break;
      }
    }
    if (sellerType == "Seller") {
      cancelMsg(data, reason, buyerid);
    } else {
      cancelMsg(data, reason, data['selleruid']);
    }
    return true;
  }

  Future addDriverPost(data, src, dest, splace, dplace) async {
    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/orders")
        .get();
    for (var val in path1.docs) {
      if (val.data()['prod_id'] == data['id'] &&
          val.data()['quantity'] == data['quantity']) {
        await val.reference.update({"job": true});
        break;
      }
    }
    var path2 = await firestore.collection("buyer/" + userID + "/orders").get();
    for (var val in path2.docs) {
      if (!val.exists) {
        return false;
      }
      if (val.data()['prod_id'] == data['id'] &&
          val.data()['quantity'] == data['quantity']) {
        await val.reference.update({"job": true});
        break;
      }
    }
    var path =
        firestore.collection("buyer").doc(userID).collection("transport");
    path.doc().set({
      "src": src,
      "dest": dest,
      "splace": splace,
      "dplace": dplace,
      "id": data['id'],
      "sellerid": data['selleruid'],
      "quantity": data['quantity'],
      "confirm": false,
    });
  }

  Future<Map> dataFetch(id, str) async {
    Map map = {};
    var path2 = await firestore
        .collection("seller")
        .doc(id)
        .collection("products")
        .get();
    for (var val2 in path2.docs) {
      if (!val2.exists) {
        return map;
      }
      if (val2.data()['id'] == str) {
        map.addAll(val2.data());
      }
    }
    return map;
  }

  Future cancelDriver(data) async {
    if (sellerType == "Driver") {
      String uid = "";
      var path1 = await firestore
          .collection("driver")
          .doc(userID)
          .collection("work")
          .get();
      for (var i in path1.docs) {
        if (i.data()['prod_id'] == data['id']) {
          uid = i.data()['buyerid'];
          i.reference.delete();
          break;
        }
      }
      path1 = await firestore
          .collection("buyer")
          .doc(uid)
          .collection("transport")
          .get();
      for (var i in path1.docs) {
        if (i.data()['id'] == data['id']) {
          i.reference.update({"confirm": false});
          break;
        }
      }
    } else {
      var path1 = await firestore
          .collection("buyer")
          .doc(userID)
          .collection("transport")
          .get();
      for (var i in path1.docs) {
        if (i.data()['id'] == data['id']) {
          i.reference.update({"confirm": false});
          break;
        }
        path1 = await firestore.collection("driver").get();
        for (var i in path1.docs) {
          var tmp = await i.reference.collection("work").get();
          for (var j in tmp.docs) {
            if (j.data()['id'] == data['id']) {
              j.reference.delete();
            }
          }
        }
      }
    }
    notifyListeners();
  }

  Future<List> getAllJob() async {
    List list = [];
    var driverPath = await firestore
        .collection("driver")
        .doc(userID)
        .collection("work")
        .get();
    var path1 = await firestore.collection("buyer").get();
    for (var val1 in path1.docs) {
      if (!val1.exists) {
        continue;
      }
      var tmp = await val1.reference.collection("transport").get();
      for (var val2 in tmp.docs) {
        if (!val2.exists || val2.data()['confirm']) {
          continue;
        }
        if (driverPath.docs.isNotEmpty) {
          for (var j in driverPath.docs) {
            if (j.data()['prod_id'] == val2['id']) {
              continue;
            }
            Map<dynamic, dynamic> v =
                await dataFetch(val2.data()['sellerid'], val2.data()['id']);
            Map<dynamic, dynamic> m = val1.data().cast();
            v.addAll(m);
            v.addAll(val2.data());
            list.add(v);
          }
        } else {
          Map<dynamic, dynamic> v =
              await dataFetch(val2.data()['sellerid'], val2.data()['id']);
          Map<dynamic, dynamic> m = val1.data().cast();
          v.addAll(m);
          v.addAll(val2.data());
          list.add(v);
        }
      }
    }
    return list;
  }

  Future review(data, String t1, int v1, String t2, int v2) async {
    var path =
        firestore.collection("seller/" + data['selleruid'] + "/review").doc();
    path.set({"text": t1, "val": v1});
    var path2 = await firestore.collection("driver").get();
    for (var i in path2.docs) {
      print(i.data());
      var path3 = await i.reference.collection("work").get();
      for (var j in path3.docs) {
        if (j.data()['prod_id'] == data['id']) {
          i.reference.collection("review").doc().set({"text": t2, "val": v2});
        }
      }
    }
  }

  Future<bool> cancelDriverRequest(sellerUID, buyerUID, prodID) async {
    var path2 = await firestore.collection("driver").get();
    String url = "https://fcm.googleapis.com/fcm/send";
    String driverToken;
    for (var val in path2.docs) {
      var aq = await val.reference.collection('work').get();
      for (var i in aq.docs) {
        if (i.data()['prod_id'] == prodID &&
            i.data()['buyerid'] == buyerUID &&
            i.data()['sellerid'] == sellerUID) {
          if (!i.exists) {
            return false;
          }
          driverToken = val.data()['msgtoken'];
          try {
            var res = await http.post(
              Uri.parse(url),
              body: json.encode(
                {
                  "to": driverToken,
                  "notification": {
                    "title": "Message from Buyer",
                    "body": "Your request is cancelled.",
                    "mutable_content": true,
                    "sound": "Tri-tone"
                  },
                },
              ),
              headers: {
                "Content-Type": "application/json",
                "Authorization":
                    "key=AAAAdJnytpc:APA91bF-guvtNJ2MEM6jEMA633MN_xXheHsrg6HH_pp5zdOdwvrWMdEGEeCeKjzeKsYS_epMWFzmSvA0FvbAydVvoX0iKp2BcKtTUYywn71yy8c8yCA1lXlJ1JHMWRqEvVNCXpwS-UiA"
              },
            );
            debugPrint(res.body);
          } catch (e) {
            debugPrint(e.toString());
          } finally {
            i.reference.delete();
          }
          break;
        }
      }
    }
    return true;
  }

  Future<bool> addDriverConfirm(data) async {
    var path =
        await firestore.collection("buyer/" + userID + "/transport").get();
    for (var val in path.docs) {
      if (val.data()['id'] == data['id']) {
        if (!val.exists) {
          return false;
        }
        val.reference.update({"confirm": true});
        break;
      }
      notifyListeners();
    }
    dynamic drivertoken;
    var path2 = await firestore.collection("driver").get();
    for (var val in path2.docs) {
      var aq = await val.reference.collection('work').get();
      for (var i in aq.docs) {
        if (i.data()['prod_id'] == data['prod_id']) {
          if (!i.exists) {
            return false;
          }
          drivertoken = val.data()['msgtoken'];
          i.reference.update({"confirm": true});
          break;
        }
      }
    }
    driverMsg(data, "confirmed", drivertoken);
    return true;
  }

  Future<List> getDriverIndiJob() async {
    List list = [];
    var path1 = await firestore
        .collection("driver")
        .doc(userID)
        .collection("work")
        .get();
    for (var i in path1.docs) {
      if (!i.exists) {
        continue;
      }
      Map v = i.data();
      var path2 = await firestore
          .collection("seller")
          .doc(i.data()['sellerid'])
          .collection("products")
          .get();
      for (var j in path2.docs) {
        if (i.data()['prod_id'] == j.data()['id']) {
          v.addAll(j.data());
        }
      }
      var path3 = await firestore
          .collection("buyer")
          .doc(i.data()['buyerid'])
          .collection("transport")
          .get();
      for (var k in path3.docs) {
        if (i.data()['prod_id'] == k.data()['id']) {
          v.addAll(k.data());
          list.add(v);
        }
      }
    }
    return list;
  }

  Future<List> getIndiJob() async {
    List list = [];
    var path1 = await firestore
        .collection("buyer")
        .doc(userID)
        .collection("transport")
        .get();
    for (var val1 in path1.docs) {
      if (!val1.exists) {
        continue;
      }
      var path2 = await firestore
          .collection("seller")
          .doc(val1.data()['sellerid'])
          .collection("products")
          .get();
      for (var val2 in path2.docs) {
        if (!val2.exists) {
          continue;
        }
        if (val2.data()['id'] == val1.data()['id']) {
          Map v = val2.data();
          v.addAll(val1.data());
          list.add(v);
        }
      }
    }
    return list;
  }

  Future isDataContainInMysql(bool b, String type) async {
    DocumentReference<Map<String, dynamic>> path;
    if (type == "Seller") {
      path =
          firestore.collection("seller").doc(authentication.currentUser!.uid);
    } else if (type == "Buyer") {
      path = firestore.collection("buyer").doc(authentication.currentUser!.uid);
    } else {
      path =
          firestore.collection("driver").doc(authentication.currentUser!.uid);
    }
    if (b) {
      try {
        path.set({"uid": userID, "data": true, "type": type});
        sellerType = type;
      } catch (e) {
        debugPrint(e.toString());
      }
      dataContainInMysql = true;
    } else {
      var r = await path.get();
      if (r.data() != null) {
        dataContainInMysql = r.data()!['data'] ?? false;
        sellerType = r.data()!['type'] ?? "loading";
      } else {
        dataContainInMysql = false;
      }
    }
    notifyListeners();
  }

  Future updateToken() async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      DocumentReference<Map<String, dynamic>> path;
      if (sellerType == "Seller") {
        path = firestore.collection("seller").doc(userID);
      } else if (sellerType == "Buyer") {
        path = firestore.collection("buyer").doc(userID);
      } else {
        path = firestore.collection("driver").doc(userID);
      }
      path.update({"msgtoken": token});
    } catch (e) {}
  }

  Future myPostDriver(data) async {
    driverMsg(data, "requested", data['msgtoken']);
    var path = firestore.collection("driver/" + userID + "/work").doc();
    path.set({
      "prod_confirm": false,
      "prod_id": data['id'],
      "sellerid": data['selleruid'],
      "buyerid": data['uid'],
      "confirm": false,
    });
    notifyListeners();
  }

  Future<String> getTokenByUID(String uid) async {
    dynamic path;
    if (sellerType == "Seller") {
      path = await firestore.collection("buyer").doc(uid).get();
    } else if (sellerType == "Buyer") {
      path = await firestore.collection("seller").doc(uid).get();
    }
    var msgtoken = await path.data()!['msgtoken'];
    return msgtoken;
  }

  void cancelMsg(prod, reason, String id) async {
    var msgid = id.isEmpty ? userID : id;
    String url = "https://fcm.googleapis.com/fcm/send";
    var message = prod['quantity'] +
        prod['measure'] +
        " of " +
        prod['product_name'] +
        " is Cancelled..";
    try {
      var res = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "to": await getTokenByUID(msgid),
            "notification": {
              "title": message,
              "body": "Reason :" + reason,
              "mutable_content": true,
              "sound": "Tri-tone",
            },
          },
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAdJnytpc:APA91bF-guvtNJ2MEM6jEMA633MN_xXheHsrg6HH_pp5zdOdwvrWMdEGEeCeKjzeKsYS_epMWFzmSvA0FvbAydVvoX0iKp2BcKtTUYywn71yy8c8yCA1lXlJ1JHMWRqEvVNCXpwS-UiA"
        },
      );
      debugPrint(res.body);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void msg(Map prod, String sts, String buyerid) async {
    String url = "https://fcm.googleapis.com/fcm/send";
    var tokenuid = buyerid.isEmpty ? prod['selleruid'] : buyerid;
    var message = prod['quantity'] +
        prod['measure'] +
        " of " +
        prod['product_name'] +
        " is " +
        sts;
    try {
      var res = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "to": await getTokenByUID(tokenuid),
            "notification": {
              "title": "Message from " + sellerType,
              "body": message,
              "mutable_content": true,
              "sound": "Tri-tone"
            },
          },
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAdJnytpc:APA91bF-guvtNJ2MEM6jEMA633MN_xXheHsrg6HH_pp5zdOdwvrWMdEGEeCeKjzeKsYS_epMWFzmSvA0FvbAydVvoX0iKp2BcKtTUYywn71yy8c8yCA1lXlJ1JHMWRqEvVNCXpwS-UiA"
        },
      );
      debugPrint(res.body);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void driverMsg(Map prod, String sts, String token) async {
    String url = "https://fcm.googleapis.com/fcm/send", message;
    late List list;
    if (sts != "Delivery") {
      list = await getData(userID);
      if (sts == "requested") {
        message = "Driver " +
            list[1] +
            " is " +
            sts +
            " to take " +
            prod['product_name'];
      } else {
        message = "Buyer " + list[1] + " is accepted your request";
      }
    } else {
      message = "Product is Delivered";
    }
    try {
      var res = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            "to": token,
            "notification": {
              "title": "Message from " + sellerType,
              "body": message,
              "mutable_content": true,
              "sound": "Tri-tone"
            },
          },
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "key=AAAAdJnytpc:APA91bF-guvtNJ2MEM6jEMA633MN_xXheHsrg6HH_pp5zdOdwvrWMdEGEeCeKjzeKsYS_epMWFzmSvA0FvbAydVvoX0iKp2BcKtTUYywn71yy8c8yCA1lXlJ1JHMWRqEvVNCXpwS-UiA"
        },
      );
      debugPrint(res.body);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> deleteProduct(data) async {
    dynamic buyerid;
    Future buyDel() async {
      var path2 =
          await firestore.collection("buyer/" + buyerid + "/orders").get();
      for (var val in path2.docs) {
        if (!val.exists) {
          return;
        }
        if (val.data()['prod_id'] == data['id']) {
          await val.reference.delete();
        }
      }
    }

    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/orders")
        .get();
    for (var val in path1.docs) {
      if (val.data()['prod_id'] == data['id']) {
        buyerid = val.data()['buyer_id'];
        await buyDel();
        await val.reference.delete();
        break;
      }
    }
    var path3 = await firestore
        .collection("seller/" + data['selleruid'] + "/products")
        .get();
    for (var val in path3.docs) {
      if (val.data()['id'] == data['id']) {
        await val.reference.delete();
        break;
      }
    }
    return true;
  }

  Future<bool> updateProduct(
      id, name, price, type, url, quantity, measure) async {
    try {
      var a = {
        "product_name": name,
        "price": price,
        "type": type,
        "imageURL": url,
        "stock": quantity,
        "measure": measure,
        "selleruid": userID,
      };
      var res = await firestore
          .collection("seller")
          .doc(userID)
          .collection("products")
          .get();
      for (var i in res.docs) {
        if (i.data()['id'] == id) {
          i.reference.update(a);
        }
      }
      update();
      myPostSeller();
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint(error.toString());
    }
    return false;
  }

  Future<bool> addProduct(name, price, type, url, quantity, measure) async {
    try {
      var a = {
        "id": DateTime.now(),
        "product_name": name,
        "price": price,
        "type": type,
        "imageURL": url,
        "stock": quantity,
        "measure": measure,
        "selleruid": userID,
      };
      await firestore
          .collection("seller")
          .doc(userID)
          .collection("products")
          .add(a);
      sellerList.add(a);
      myProdSel.add(a);
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint(error.toString());
    }
    return false;
  }

  Future addRequest(Map data, String quantity) async {
    try {
      //data contain sellerid
      var sellerPath =
          firestore.collection("seller/" + data['selleruid'] + "/orders").doc();
      var buyerPath = firestore.collection("buyer/" + userID + "/orders").doc();
      sellerPath.set({
        "buyer_id": userID,
        "prod_id": data['id'],
        "confirm": false,
        "quantity": quantity,
        "job": false
      });
      buyerPath.set({
        "seller_id": data['selleruid'],
        "prod_id": data['id'],
        "confirm": false,
        "quantity": quantity,
        "job": false
      });
      msg(data, "Requested", "");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> addConfirm(Map data) async {
    dynamic buyerid;
    var path = await firestore
        .collection("seller/" + data['selleruid'] + "/products")
        .get();
    for (var val in path.docs) {
      if (val.data()['id'] == data['id']) {
        if (!val.exists) {
          return false;
        }
        var a = (int.parse(val.data()['stock']) - int.parse(data['quantity']))
            .toString();
        val.reference.update({"stock": a});
        update();
        myPostSeller();
        break;
      }
    }

    var path1 = await firestore
        .collection("seller/" + data['selleruid'] + "/orders")
        .get();
    for (var val in path1.docs) {
      if (!val.exists) {
        return false;
      }
      if (val.data()['prod_id'] == data['id'] &&
          val.data()['confirm'] != true) {
        buyerid = val.data()['buyer_id'];
        await val.reference.update({"confirm": true});
        break;
      }
    }
    if (buyerid == null) {
      return false;
    }
    var path2 =
        await firestore.collection("buyer/" + buyerid + "/orders").get();
    for (var val in path2.docs) {
      if (!val.exists) {
        return false;
      }
      if (val.data()['prod_id'] == data['id'] &&
          val.data()['confirm'] != true) {
        await val.reference.update({"confirm": true});
        break;
      }
    }
    msg(data, "Confirmed", buyerid);
    return true;
  }

  void myPostBuyer(c) {
    if (myProdBuy.contains(c)) {
      return;
    }
    myProdBuy.add(c);
  }

  void myPostSeller() async {
    //individual seller post
    myProdSel = [];
    var res =
        await firestore.collection("seller/" + userID + "/products").get();
    for (var d1 in res.docs) {
      myProdSel.add(d1.data());
    }
    notifyListeners();
  }

  void update() async {
    //all seller post
    sellerList.clear();
    var alldata = await firestore.collection("seller/").get();
    try {
      for (var d1 in alldata.docs) {
        var uid = d1.data()['uid']; //uid
        var productData =
            await firestore.collection("seller/" + uid + "/products").get();
        if (productData.docs.isEmpty) {
          continue;
        }
        for (var d2 in productData.docs) {
          sellerList.add(d2.data());
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  int getListLength() {
    return sellerList.length;
  }

  int getMyListLength() {
    return sellerType == "Seller" ? myProdSel.length : myProdBuy.length;
  }
}
