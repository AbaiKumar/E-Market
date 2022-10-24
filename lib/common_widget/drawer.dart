// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/driver_order.dart';
import 'package:market/Seller_Buyer_module/order.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var a = Provider.of<SellerPost>(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: Icon(Icons.shopping_cart),
            ),
            accountName: Text(
              a.sellerType,
              overflow: TextOverflow.ellipsis,
            ),
            accountEmail: Text(a.userEmail ?? "hi"),
          ),
          if (a.sellerType != "Driver")
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout_outlined),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.topLeft,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Order(),
                    ),
                  );
                },
                label: Container(
                  margin: const EdgeInsets.only(left: 25),
                  child: const Text(
                    "Orders",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          if (a.sellerType != "Seller")
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.local_shipping_outlined),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.topLeft,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DriverOrder(),
                    ),
                  );
                },
                label: Container(
                  margin: const EdgeInsets.only(left: 25),
                  child: const Text(
                    "Driver",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.logout_outlined),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.topLeft,
              ),
              onPressed: () {
                SellerPost.authentication.signOut();
                SellerPost.appRestart();
              },
              label: Container(
                margin: const EdgeInsets.only(left: 25),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
