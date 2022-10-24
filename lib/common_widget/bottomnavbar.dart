// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market/model/sellerpost.dart';

class BottomNav extends StatefulWidget {
  final Function fun;
  const BottomNav(this.fun);
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int curIndx = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SellerPost prov = Provider.of(context);
    return BottomNavigationBar(
      unselectedItemColor: Colors.black45,
      currentIndex: curIndx,
      onTap: (ind) {
        widget.fun(ind);
        curIndx = ind;
      },
      items: [
        BottomNavigationBarItem(
          icon: curIndx == 0
              ? const Icon(Icons.home_sharp)
              : const Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: curIndx == 1
              ? const Icon(Icons.list_alt_sharp)
              : const Icon(Icons.list_alt_outlined),
          label: prov.sellerType == "Driver" ? "My Job" : "My List",
        ),
        if (prov.sellerType == "Buyer")
          BottomNavigationBarItem(
            icon: curIndx == 2
                ? const Icon(Icons.local_shipping_outlined)
                : const Icon(Icons.local_shipping_rounded),
            label: "Driver",
          ),
      ],
    );
  }
}
