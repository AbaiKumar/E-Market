// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/elaborate.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Order extends StatefulWidget {
  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List requestList = [];
  List confirmList = [];
  final TextEditingController _text1 = TextEditingController();
  final TextEditingController _text2 = TextEditingController();
  final TextEditingController _text3 = TextEditingController();
  final TextEditingController _text4 = TextEditingController();
  late SellerPost a;

  @override
  void dispose() {
    super.dispose();
    _text1.dispose();
    _text2.dispose();
    _text3.dispose();
    _text4.dispose();
  }

  void getProductFromNetwork(SellerPost a, Map sellerDetails) async {
    dynamic sellerPath;
    if (a.sellerType == "Buyer") {
      sellerPath = await a.firestore
          .collection("seller/" + sellerDetails['seller_id'] + "/products")
          .get();
    } else {
      sellerPath = await a.firestore
          .collection("seller/" + a.userID + "/products")
          .get();
    }
    for (var data in sellerPath.docs) {
      if (data.data()['id'] == sellerDetails['prod_id']) {
        Map<String, dynamic> a = data.data();
        a.addAll({
          "uid": sellerDetails['buyer_id'],
          "quantity": sellerDetails['quantity'],
          "job": sellerDetails['job'],
        });
        if (!sellerDetails['confirm']) {
          requestList.add(a);
        } else {
          confirmList.add(a);
        }
      }
    }
    setState(() {});
    return;
  }

  Future dataFetch(SellerPost a) async {
    requestList.clear();
    confirmList.clear();
    setState(() {});
    if (a.sellerType == "Seller") {
      var sellerPath =
          await a.firestore.collection("seller/" + a.userID + "/orders").get();
      for (var data in sellerPath.docs) {
        getProductFromNetwork(a, data.data());
      }
    } else {
      var buyerPath =
          await a.firestore.collection("buyer/" + a.userID + "/orders").get();
      for (var data in buyerPath.docs) {
        getProductFromNetwork(
          a,
          data.data(),
        );
      }
    }
  }

  void set() {
    dataFetch(a);
  }

  Widget request(SellerPost a) {
    return RefreshIndicator(
      onRefresh: () => dataFetch(a),
      child: requestList.isNotEmpty
          ? ListView.builder(
              itemCount: requestList.length,
              itemBuilder: (context, index) {
                return con(requestList[index], "request");
              })
          : const Text(''),
    );
  }

  Widget confirm(SellerPost a) {
    return RefreshIndicator(
      onRefresh: () => dataFetch(a),
      child: ListView.builder(
          itemCount: confirmList.length,
          itemBuilder: (context, index) {
            return con(confirmList[index], "confirm");
          }),
    );
  }

  Widget con(Map data, String status) {
    if (data.isEmpty) {
      return const CircularProgressIndicator();
    }
    return GestureDetector(
      onTap: () {
        if ((a.sellerType == "Seller" && status != "request" && data['job']) ||
            (a.sellerType == "Buyer" && status != "request" && data['job'])) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Elaborate(data, true),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Elaborate(data, false),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Card(
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 3.0,
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.all(5),
                      height: 150,
                      width: MediaQuery.of(context).size.width * 0.41,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10.0), //add border radius
                        child: Hero(
                          tag: data,
                          child: Image.network(
                            data['imageURL'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      )),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      alignment: Alignment.centerLeft,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['product_name'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "1 " +
                                data['measure'].toString() +
                                "=₹" +
                                (data['price']).toString(),
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (status == 'request')
                            Text(
                              "Stock :" + data['stock'] + " " + data['measure'],
                              style: GoogleFonts.getFont(
                                "Lato",
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          Text(
                            "Order : " +
                                data['quantity'] +
                                " " +
                                data['measure'],
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Amount :₹" +
                                (int.parse(data['price']) *
                                        int.parse(data['quantity']))
                                    .toString(),
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (!data['job'])
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (status != "request") {
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
                                        child: Wrap(
                                          children: <Widget>[
                                            TextField(
                                              maxLength: 50,
                                              controller: _text1,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    'Enter Reason for Cancellation',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_text1.text.isEmpty) {
                                            return;
                                          }
                                          Navigator.of(context).pop();
                                          await a.cancelProduct(
                                              data, _text1.text);
                                          await a.updateCancel(data);
                                          if (confirmList.length == 1) {
                                            setState(() {
                                              confirmList = [];
                                            });
                                          } else {
                                            await dataFetch(a);
                                          }
                                          _text1.clear();
                                          FocusScope.of(context).unfocus();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Cancelled Successfully"),
                                            ),
                                          );
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            await a.cancelProduct(data, "Cancelled");
                            if (confirmList.length == 1) {
                              setState(() {
                                confirmList = [];
                              });
                            } else {
                              await dataFetch(a);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            primary: Colors.red),
                        child: const Text('Cancel'),
                      ),
                    ),
                  if (a.sellerType == "Seller")
                    Expanded(
                      child: Container(
                        alignment:
                            status == "request" ? null : Alignment.center,
                        padding: status == "request"
                            ? null
                            : const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        color: status == "request" ? null : Colors.green,
                        child: status == "request"
                            ? ElevatedButton(
                                onPressed: () async {
                                  bool b = await a.addConfirm(data);
                                  if (!b) {
                                    await dataFetch(a);
                                    setState(() {});
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
                                child: const Text('confirm order'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                ),
                              )
                            : const Text("Confirmed"),
                      ),
                    ),
                  if (a.sellerType == "Buyer")
                    Expanded(
                      child: Container(
                        alignment:
                            status == "request" ? Alignment.center : null,
                        padding: const EdgeInsets.all(10),
                        margin: status == "request"
                            ? const EdgeInsets.only(left: 10, right: 10)
                            : null,
                        color: status == "request" ? Colors.green : null,
                        child: (status == "request")
                            ? const Text("In Progress")
                            : ElevatedButton(
                                onPressed: !data['job']
                                    ? () {
                                        showModalBottomSheet<void>(
                                          isScrollControlled: true,
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30.0),
                                                topRight:
                                                    Radius.circular(30.0)),
                                          ),
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Wrap(
                                                        children: <Widget>[
                                                          TextField(
                                                            controller: _text1,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        'Full Source Address'),
                                                          ),
                                                          TextField(
                                                            controller: _text2,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        'Source Place'),
                                                          ),
                                                          TextField(
                                                            controller: _text3,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'Full Destination Address',
                                                            ),
                                                          ),
                                                          TextField(
                                                            controller: _text4,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        'Destination Place'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        String t1 = _text1.text,
                                                            t2 = _text2.text,
                                                            t3 = _text3.text,
                                                            t4 = _text4.text;
                                                        if (t1.isEmpty ||
                                                            t2.isEmpty ||
                                                            t3.isEmpty ||
                                                            t4.isEmpty) {
                                                          return;
                                                        }
                                                        await a.addDriverPost(
                                                            data,
                                                            t1,
                                                            t3,
                                                            t2,
                                                            t4);
                                                        _text1.clear();
                                                        _text2.clear();
                                                        _text3.clear();
                                                        _text4.clear();
                                                        Navigator.of(context)
                                                            .pop();
                                                        await dataFetch(a);
                                                        setState(() {});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "Added to job's"),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text("Hire"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: const Text('Hire Driver'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                ),
                              ),
                      ),
                    ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SellerPost.f = set;
    Future.delayed(Duration.zero, () {
      dataFetch(a);
    });
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context, listen: false);
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
            title: const Text('Order Status'),
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

class AfterDetails extends StatefulWidget {
  @override
  State<AfterDetails> createState() => _AfterDetailsState();
}

class _AfterDetailsState extends State<AfterDetails> {
  late List sellerDetails = [];
  late List buyerDetails = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 5,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seller Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text('Sourced and Marketed by : ' + sellerDetails[3]),
                Text('Seller Name :' + sellerDetails[0]),
                Text('Address :' + sellerDetails[4]),
                Text('Contact : ' + sellerDetails[2]),
                Text('Email : ' + sellerDetails[1]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
