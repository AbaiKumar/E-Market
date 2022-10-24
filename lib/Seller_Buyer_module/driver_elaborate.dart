// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

class DriverElaborate extends StatefulWidget {
  dynamic data;
  DriverElaborate(this.data);
  @override
  State<DriverElaborate> createState() => _DriverElaborateState();
}

class _DriverElaborateState extends State<DriverElaborate> {
  late Map val;
  late SellerPost a;
  late final MapController controller = MapController();
  late List driverDetails = [];

  Future<String> getDriveruid() async {
    var path = await a.firestore.collection("driver").get();
    for (var i in path.docs) {
      var innerpath = await i.reference.collection('work').get();
      for (var j in innerpath.docs) {
        if (j.data()['prod_id'] == widget.data['id']) {
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
      var str = await getDriveruid();
      if (str.isNotEmpty) {
        driverDetails = await a.getData(str);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of(context);
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Driver Detail"),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin:
                const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          Text(
                            'Driver Name :' + driverDetails[1],
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Address :' + driverDetails[5],
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Contact : ' + driverDetails[3],
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Email : ' + driverDetails[2],
                            style: GoogleFonts.getFont(
                              "Lato",
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (driverDetails.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
                    child: Review(driverDetails[0]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Review extends StatefulWidget {
  String uid;
  Review(this.uid);
  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List review = [];
  double total = 0.0;
  late SellerPost sel;

  Future getReview() async {
    var path = await sel.firestore
        .collection("driver/" + widget.uid + "/review")
        .get();
    for (var i in path.docs) {
      review.add(i.data());
    }
    Map number = {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0};
    for (var i in review) {
      if (i['val'] == 1) {
        number.update("1", (value) => number['1'] + 1);
      } else if (i['val'] == 2) {
        number.update("2", (value) => number['2'] + 1);
      } else if (i['val'] == 3) {
        number.update("3", (value) => number['3'] + 1);
      } else if (i['val'] == 4) {
        number.update("4", (value) => number['4'] + 1);
      } else if (i['val'] == 5) {
        number.update("5", (value) => number['5'] + 1);
      }
    }
    num mul = 0;
    for (var j in number.keys) {
      mul += (number[j] * int.parse(j));
    }
    total = mul / review.length;
    if (total.isNaN) {
      total = 0;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getReview();
      setState(() {});
    });
  }

  Widget con(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            Text(review[index]['val'].toString()),
          ],
        ),
        Container(
          margin: const EdgeInsets.all(10),
          child: Text(review[index]['text']),
        ),
        const Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    sel = Provider.of(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.star,
              size: 30,
              color: Colors.amber,
            ),
            Text(
              total.toString(),
              style: GoogleFonts.getFont(
                "Lato",
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(review.length.toString() + " reviews and rating"),
        const Divider(
          thickness: 2,
        ),
        ListView.builder(
          itemBuilder: (context, index) {
            return con(index);
          },
          shrinkWrap: true,
          itemCount: review.length,
        ),
      ],
    );
  }
}
