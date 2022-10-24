// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Search extends StatefulWidget {
  String val;
  Search(this.val);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _txtcontroller = TextEditingController();
  late SellerPost a;
  List lis = [];

  Widget con(context, dynamic c, SellerPost a) {
    return Container(
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 3.0,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(10),
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10.0), //add border radius
                      child: Image.network(
                        c['imageURL'],
                        fit: BoxFit.fill,
                      ),
                    )),
                Expanded(
                  child: Container(
                    height: 130,
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['product_name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(5),
                          child: const Text('1 Kg'),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.1),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹" + c['price'],
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (a.sellerType == "Buyer")
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                child: ElevatedButton(
                  onPressed: () {
                    a.myPostBuyer(c);
                  },
                  child: const Text("Add"),
                ),
              ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _txtcontroller.text = widget.val;
    Future.delayed(Duration.zero, () => valueUpdate(widget.val));
  }

  @override
  void dispose() {
    super.dispose();
    _txtcontroller.dispose();
  }

  void valueUpdate(String val) {
    lis = [];
    if (val.isEmpty) {
      lis = a.sellerList;
      return;
    }
    for (var i in a.sellerList) {
      if (i['product_name']
          .toString()
          .toLowerCase()
          .contains(val.toLowerCase())) {
        lis.add(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context, listen: false);

    return Theme(
      data: themeData,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                  centerTitle: true,
                  title: const Text(
                    'Search Products',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  pinned: true,
                  floating: true,
                  bottom: PreferredSize(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 47,
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: TextField(
                          controller: _txtcontroller,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: "Search products",
                            prefixIcon: Icon(Icons.search_outlined),
                          ),
                          onEditingComplete: () {
                            valueUpdate(_txtcontroller.text);
                          },
                        ),
                      ),
                      preferredSize: const Size(double.infinity, 70))),
            ];
          },
          body: ListView.builder(
            itemCount: lis.length,
            itemBuilder: (context, index) => contact1(context, lis[index], a),
          ),
        ),
      ),
    );
  }
}
