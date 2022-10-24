// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';

class Review extends StatefulWidget {
  String uid, type;
  Review(this.uid, this.type);
  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List review = [];
  double total = 0.0;
  late SellerPost sel;

  Future getReview() async {
    if (widget.type == "seller") {
      var path = await sel.firestore
          .collection("seller/" + widget.uid + "/review")
          .get();
      for (var i in path.docs) {
        if (i.exists) {
          review.add(i.data());
        }
      }
    } else {
      var path = await sel.firestore
          .collection("driver/" + widget.uid + "/review")
          .get();
      for (var i in path.docs) {
        review.add(i.data());
      }
    }
    Map number = {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0};
    for (var i in review) {
      if (i['val'] == 1) {
        number.update("1", (value) => number['1'] + 1);
      }
      if (i['val'] == 2) {
        number.update("2", (value) => number['2'] + 1);
      }
      if (i['val'] == 3) {
        number.update("3", (value) => number['3'] + 1);
      }
      if (i['val'] == 4) {
        number.update("4", (value) => number['4'] + 1);
      }
      if (i['val'] == 5) {
        number.update("5", (value) => number['5'] + 1);
      }
    }
    num mul = 0;
    for (var j in number.keys) {
      mul += (number[j] * int.parse(j));
    }
    total = mul / review.length;
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
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(title: const Text("Reviews")),
        body: review.isNotEmpty
            ? Column(
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
                        style: const TextStyle(fontSize: 30),
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
              )
            : const Text('No Reviews Found'),
      ),
    );
  }
}
