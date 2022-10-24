// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';

class StarRating extends StatefulWidget {
  dynamic data;
  StarRating(this.data);
  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int value1 = -1;
  int value2 = -1;
  late SellerPost a;
  TextEditingController txt1 = TextEditingController();
  TextEditingController txt2 = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    txt1.dispose();
    txt2.dispose();
    value1 = 0;
    value2 = 0;
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context, listen: false);
    return Theme(
      data: ThemeData(
        iconTheme: const IconThemeData(size: 30, color: Colors.amber),
        focusColor: Colors.green,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Seller Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          value1 = index;
                        });
                      },
                      icon: Icon(
                        index <= value1 ? Icons.star : Icons.star_border,
                      ),
                    );
                  }),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                        label: Text("Review"), fillColor: Colors.grey),
                    textInputAction: TextInputAction.done,
                    controller: txt1,
                    maxLines: 2,
                    maxLength: 100,
                    keyboardType: TextInputType.text,
                  ),
                )
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Driver Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          value2 = index;
                        });
                      },
                      icon: Icon(
                        index <= value2 ? Icons.star : Icons.star_border,
                      ),
                    );
                  }),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                        label: Text("Review"), fillColor: Colors.grey),
                    textInputAction: TextInputAction.done,
                    controller: txt2,
                    maxLines: 2,
                    maxLength: 100,
                    keyboardType: TextInputType.text,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      a.review(widget.data, txt1.text, value1 + 1, txt2.text,
                          value2 + 1);
                      Navigator.pop(context);
                    },
                    child: const Text("Submit"))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
