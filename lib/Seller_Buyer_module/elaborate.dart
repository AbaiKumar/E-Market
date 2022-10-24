// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/review_expand.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Elaborate extends StatefulWidget {
  dynamic data;
  bool status;
  Elaborate(this.data, this.status);
  @override
  State<Elaborate> createState() => _ElaborateState();
}

class _ElaborateState extends State<Elaborate> {
  late Map val;
  late SellerPost a;
  late final MapController controller = MapController();
  final TextEditingController _textController = TextEditingController();
  late List sellerDetails = [];
  late List driverDetails = [];
  late List buyerDetails = [];

  Future<String> getDriveruid() async {
    var path = await a.firestore.collection("driver").get();
    for (var i in path.docs) {
      var innerpath = await i.reference.collection('work').get();
      for (var j in innerpath.docs) {
        if (j.data()['confirm'] && j.data()['prod_id'] == widget.data['id']) {
          return i.data()['uid'];
        }
      }
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.status) {
        sellerDetails = await a.getData(widget.data['selleruid']);
        setState(() {});
        if (widget.data['uid'] != null) {
          buyerDetails = await a.getData(widget.data['uid']);
        }
        var str = await getDriveruid();
        if (str.isNotEmpty) {
          driverDetails = await a.getData(str);
        }
      } else {
        try {
          sellerDetails = await a.getData(widget.data['selleruid']);
          setState(() {});
          buyerDetails = await a.getData(widget.data['uid']);
        } catch (e) {}
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of(context);
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (a.sellerType != "Driver")
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("OrderStatus");
                },
                icon: const Icon(Icons.shopping_cart_checkout_outlined),
              ),
            const SizedBox(
              width: 5,
            )
          ],
        ),
        body: Theme(
          data: ThemeData(
              textTheme: const TextTheme(
            bodyText2:
                TextStyle(fontStyle: FontStyle.normal, color: Colors.black54),
          )),
          child: SingleChildScrollView(
            child: Container(
              margin:
                  const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['product_name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w300, fontSize: 25),
                  ),
                  if (a.sellerType != "Driver")
                    Text(
                      "1 " +
                          widget.data['measure'] +
                          " = ₹ " +
                          widget.data['price'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 20),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Hero(
                      tag: widget.data,
                      child: Image.network(
                        widget.data['imageURL'],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  if (a.sellerType == "Buyer")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0)),
                            ),
                            builder: (BuildContext context) {
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(20),
                                      child: Text(
                                        "Available Stock : " +
                                            widget.data['stock'] +
                                            " " +
                                            widget.data['measure'],
                                        style: GoogleFonts.getFont(
                                          "Lato",
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(20),
                                      child: Wrap(
                                        children: <Widget>[
                                          TextField(
                                            controller: _textController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter Quantity in ' +
                                                  widget.data['measure'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.green),
                                      onPressed: () {
                                        if (_textController.text.isEmpty) {
                                          return;
                                        }
                                        if (int.parse(_textController.text) <=
                                                int.parse(
                                                    widget.data['stock']) &&
                                            int.parse(_textController.text) >
                                                0) {
                                          Map val = {
                                            "quantity": _textController.text,
                                            "request": false,
                                          };
                                          val.addAll(widget.data);
                                          a.myProdBuy.add(val);
                                          Navigator.of(context).pop();
                                          FocusScope.of(context).unfocus();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text("Added to My List"),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("Add to My List"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Text('Add to My List'),
                      ),
                    ),
                  if (sellerDetails.isNotEmpty) ...[
                    Card(
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seller Details',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text('Sourced and Marketed by : ' +
                                sellerDetails[3]),
                            Text('Seller Name :' + sellerDetails[1]),
                            Text('Address :' + sellerDetails[5]),
                            Text('Contact : ' + sellerDetails[3]),
                            Text('Email : ' + sellerDetails[2]),
                            TextButton.icon(
                              style:
                                  TextButton.styleFrom(primary: Colors.green),
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.fastLinearToSlowEaseIn,
                                      );
                                      return ScaleTransition(
                                        scale: animation,
                                        alignment: Alignment.center,
                                        child: child,
                                      );
                                    },
                                    pageBuilder: ((context, animation,
                                            secondaryAnimation) =>
                                        Review(sellerDetails[0], "seller")),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.reviews_outlined),
                              label: const Text(" View Review"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 250,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          interactiveFlags:
                              InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          center: LatLng(double.parse(sellerDetails[6]),
                              double.parse(sellerDetails[7])),
                          zoom: 16.0,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                            attributionBuilder: (_) {
                              return Container(
                                margin: const EdgeInsets.all(5),
                                child: const Text(
                                  "Seller",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          ),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(double.parse(sellerDetails[6]),
                                    double.parse(sellerDetails[7])),
                                builder: (ctx) => Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 27,
                                    ),
                                    Text(
                                      "Market",
                                      style: TextStyle(fontSize: 12.5),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                  if (buyerDetails.isNotEmpty) ...[
                    Card(
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Buyer Details',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text('Sourced and Marketed by : ' +
                                sellerDetails[3]),
                            Text('Seller Name :' + buyerDetails[1]),
                            Text('Address :' + buyerDetails[5]),
                            Text('Contact : ' + buyerDetails[3]),
                            Text('Email : ' + buyerDetails[2]),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 250,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          interactiveFlags:
                              InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          center: LatLng(double.parse(buyerDetails[6]),
                              double.parse(buyerDetails[7])),
                          zoom: 16.0,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                            attributionBuilder: (_) {
                              return Container(
                                margin: const EdgeInsets.all(5),
                                child: const Text(
                                  "Buyer",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          ),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(double.parse(buyerDetails[6]),
                                    double.parse(buyerDetails[7])),
                                builder: (ctx) => Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 27,
                                    ),
                                    Text(
                                      "Market",
                                      style: TextStyle(fontSize: 12.5),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                  if (driverDetails.isNotEmpty)
                    Card(
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Driver Details',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text('Seller Name :' + driverDetails[1]),
                            Text('Address :' + driverDetails[5]),
                            Text('Contact : ' + driverDetails[3]),
                            Text('Email : ' + driverDetails[2]),
                            TextButton.icon(
                              style:
                                  TextButton.styleFrom(primary: Colors.green),
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.fastLinearToSlowEaseIn,
                                      );
                                      return ScaleTransition(
                                        scale: animation,
                                        alignment: Alignment.center,
                                        child: child,
                                      );
                                    },
                                    pageBuilder: ((context, animation,
                                            secondaryAnimation) =>
                                        Review(driverDetails[0], "driver")),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.reviews_outlined),
                              label: const Text(" View Review"),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
