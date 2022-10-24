// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:market/common_widget/commonfunctions.dart';

class MyList extends StatefulWidget {
  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  late SellerPost a;
  late int amount = 1;
  void set() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (a.sellerType == "Seller") {
        a.myPostSeller();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context);
    return a.sellerType == "Seller"
        ? ListView.builder(
            itemCount: a.getMyListLength(),
            itemBuilder: ((context, index) {
              return contact2(context, a.myProdSel[index]);
            }),
            shrinkWrap: true,
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ...(a.myProdBuy.map(
                  (e) {
                    try {
                      return BuyerRequest(e);
                    } catch (e) {
                      return const Text("");
                    }
                  },
                )).toList()
              ],
            ),
          );
  }
}
