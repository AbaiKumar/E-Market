// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:market/common_widget/commonfunctions.dart';

class Home extends StatefulWidget {
  bool chg;
  String search;
  Home(this.chg, this.search);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List filter;
  late SellerPost a;
  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 2));
    a.update();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      filter = a.sellerList;
    });
  }

  void valueUpdate() async {
    filter = [];
    if (widget.search.isEmpty) {
      filter = a.sellerList;
      return;
    }
    for (var i in a.sellerList) {
      if (i['product_name']
          .toString()
          .toLowerCase()
          .contains(widget.search.toLowerCase())) {
        filter.add(i);
      }
    }
    setState(() {});
  }

  Widget ret(SellerPost a, index) {
    return contact1(context, a.sellerList[index], a);
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context);
    valueUpdate();
    return !widget.chg
        ? RefreshIndicator(
            onRefresh: () => refreshList(),
            child: ListView.builder(
              itemCount: a.sellerList.length,
              itemBuilder: ((context, index) {
                return ret(a, index);
              }),
              shrinkWrap: true,
            ),
          )
        : ListView.builder(
            itemCount: filter.length,
            itemBuilder: ((context, index) {
              return contact1(context, filter[index], a);
            }),
            shrinkWrap: true,
          );
  }
}
