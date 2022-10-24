// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/driver_elaborate.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverOrder extends StatefulWidget {
  @override
  State<DriverOrder> createState() => _DriverOrderState();
}

class _DriverOrderState extends State<DriverOrder> {
  List requestList = [];
  List confirmList = [];
  late SellerPost a;

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map> sellerProductDetails(details, val) async {
    if (val) {
      var pather = await a.firestore
          .collection("seller/" + details['sellerid'] + "/products")
          .get();
      for (var data in pather.docs) {
        if (data.data()['id'] == details['id']) {
          return data.data();
        }
      }
    } else {
      var pather = await a.firestore
          .collection("seller/" + details['sellerid'] + "/products")
          .get();
      for (var data in pather.docs) {
        if (data.data()['id'] == details['prod_id']) {
          return data.data();
        }
      }
    }
    return {};
  }

  void getProductFromNetwork(SellerPost a, Map details) async {
    if (a.sellerType == "Driver") {
      var path = await a.firestore
          .collection("buyer/" + details['buyerid'] + "/transport")
          .get();
      for (var data in path.docs) {
        if (data.data()['id'] == details['prod_id']) {
          Map<String, dynamic> map = data.data();
          dynamic add = await sellerProductDetails(details, false);
          map.addAll(add);
          if (!data.data()['confirm']) {
            requestList.add(map);
          } else {
            confirmList.add(map);
          }
        }
      }
    } else {
      var path2 = await a.firestore.collection("driver").get();
      for (var d in path2.docs) {
        var ref = await d.reference.collection("work").get();
        for (var d1 in ref.docs) {
          if (d1.data()['prod_id'] == details['id'] &&
              d1.data()['sellerid'] == details['sellerid']) {
            Map add = await sellerProductDetails(details, true);
            add.addAll(d1.data());
            add.addAll(details);
            if (!details['confirm']) {
              requestList.add(add);
            } else {
              confirmList.add(add);
            }
          }
        }
      }
    }
    setState(() {});
  }

  Future dataFetch(SellerPost a) async {
    requestList.clear();
    confirmList.clear();
    if (a.sellerType == "Driver") {
      var sellerPath =
          await a.firestore.collection("driver/" + a.userID + "/work").get();
      for (var data in sellerPath.docs) {
        getProductFromNetwork(a, data.data());
      }
    } else {
      var buyerPath = await a.firestore
          .collection("buyer/" + a.userID + "/transport")
          .get();
      for (var data in buyerPath.docs) {
        getProductFromNetwork(
          a,
          data.data(),
        );
      }
    }
    setState(() {});
  }

  void set() {
    dataFetch(a);
  }

  Widget request(SellerPost a) {
    return RefreshIndicator(
      onRefresh: () => dataFetch(a),
      child: ListView.builder(
          itemCount: requestList.length,
          itemBuilder: (context, index) {
            return requestList.isEmpty
                ? const Text('')
                : con(requestList[index], "request");
          }),
    );
  }

  Widget confirm(SellerPost a) {
    return RefreshIndicator(
      onRefresh: () => dataFetch(a),
      child: ListView.builder(
          itemCount: confirmList.length,
          itemBuilder: (context, index) {
            return confirmList.isEmpty
                ? const Text('')
                : con(confirmList[index], "confirm");
          }),
    );
  }

  Widget con(data, status) {
    return GestureDetector(
      onTap: () {
        if (a.sellerType != "Driver") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverElaborate(data),
            ),
          );
        }
      },
      child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(10),
          child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10.0), //add border radius
                    child: Hero(
                      tag: data,
                      child: Image.network(
                        data['imageURL'],
                        fit: BoxFit.fill,
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Name : " + data['product_name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Quantity : " +
                            data['quantity'] +
                            " " +
                            data['measure'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Source Address : " + data['src'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Destination Address : " + data['dest'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (status == request)
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            await a.cancelDriver(data);
                            await dataFetch(a);
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              primary: Colors.red),
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (a.sellerType == "Buyer")
                      Expanded(
                        child: Container(
                          alignment:
                              status == "request" ? null : Alignment.center,
                          padding: status == "request"
                              ? null
                              : const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 5),
                          color: status == "request" ? null : Colors.green,
                          child: status == "request"
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          print(data);
                                          await a.cancelDriverRequest(
                                              data['selleruid'],
                                              data['buyerid'],
                                              data['prod_id']);
                                        },
                                        child: const Text('Cancel'),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(10),
                                            primary: Colors.red),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          bool b =
                                              await a.addDriverConfirm(data);
                                          if (!b) {
                                            await dataFetch(a);
                                          }
                                          if (confirmList.length == 1) {
                                            setState(() {
                                              confirmList.add((requestList));
                                              requestList = [];
                                            });
                                          } else {
                                            await dataFetch(a);
                                          }
                                        },
                                        child: const Text('Confirm Job'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Text("Confirmed"),
                        ),
                      ),
                    if (a.sellerType == "Driver")
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 5),
                          color: Colors.green,
                          child: (status == "request")
                              ? const Text("In Progress")
                              : const Text('Confirmed'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    SellerPost.f = set;
    Future.delayed(Duration.zero, () async {
      await dataFetch(a);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context);
    return Theme(
      data: themeData,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: "Request", icon: Icon(Icons.pending_actions_rounded)),
                Tab(text: "Confirmation", icon: Icon(Icons.task_alt_rounded)),
              ],
            ),
            title: const Text('Job Status'),
          ),
          body: TabBarView(
            children: <Widget>[
              request(a),
              confirm(a),
            ],
          ),
        ),
      ),
    );
  }
}
