// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:provider/provider.dart';
import 'package:market/model/sellerpost.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SellerPost sp;
  List details = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      details = await sp.getData(sp.userID);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    sp = Provider.of(context);
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account Settings',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Container(
                width: 75,
                height: 75,
                margin: const EdgeInsets.all(15),
                child: const CircleAvatar(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  child: Icon(
                    Icons.shopping_cart,
                  ),
                ),
              ),
              if (details.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name : " + details[1],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Address : " + details[5],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Contact : " + details[3],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 20, thickness: 0.7),
              ListTile(
                title: const Text("Change Password"),
                trailing: const Icon(Icons.lock_open_rounded),
                onTap: () {
                  SellerPost.authentication.sendPasswordResetEmail(
                    email: sp.userEmail.toString(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Check your email"),
                    ),
                  );
                },
              ),
              const Divider(height: 20, thickness: 0.7),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () {
                    SellerPost.authentication.signOut();
                    Navigator.of(context).pop();
                  },
                  child: const Text("logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
