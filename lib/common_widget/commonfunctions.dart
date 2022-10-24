// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/addproduct.dart';
import 'package:market/Seller_Buyer_module/elaborate.dart';
import 'package:market/model/sellerpost.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

var themeData = ThemeData(
  primarySwatch: Colors.green,
  textTheme: TextTheme(titleSmall: GoogleFonts.getFont("Roboto")),
  androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
  scaffoldBackgroundColor: Colors.white,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(color: Colors.green),
    selectedLabelStyle: TextStyle(color: Colors.green),
    selectedItemColor: Colors.green,
  ),
);

class BuyerRequest extends StatefulWidget {
  dynamic data;
  BuyerRequest(this.data);
  @override
  State<BuyerRequest> createState() => _BuyerRequestState();
}

class _BuyerRequestState extends State<BuyerRequest> {
  late final int stock;
  late final String measure;
  bool color = false;
  @override
  void initState() {
    super.initState();
    stock = int.parse(widget.data['stock']);
    measure = widget.data['measure'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var a = Provider.of<SellerPost>(context, listen: false);
    if (widget.data['request']) {
      return const SizedBox(
        height: 0,
      );
    }
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
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10.0), //add border radius
                      child: Hero(
                        tag: widget.data,
                        child: Image.network(
                          widget.data['imageURL'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    )),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data['product_name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "1 " +
                              measure.toString() +
                              " : ₹" +
                              (widget.data['price']).toString(),
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Stock : " +
                              widget.data['stock'] +
                              " " +
                              widget.data['measure'],
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Order : " +
                              widget.data['quantity'] +
                              " " +
                              widget.data['measure'],
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Amount :₹" +
                              (int.parse(widget.data['price']) *
                                      int.parse(widget.data['quantity']))
                                  .toString(),
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () async {
                  await a.addRequest(widget.data, widget.data['quantity']);
                  setState(() {
                    widget.data['request'] = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Request sended to seller.Check status in orders page"),
                    ),
                  );
                },
                child: const Text("Request"),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

Widget contact1(BuildContext context, dynamic data, SellerPost a) {
  TextEditingController _textController = TextEditingController();
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Elaborate(data, false),
        ),
      );
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
                    margin: const EdgeInsets.all(10),
                    height: 140,
                    width: MediaQuery.of(context).size.width * 0.425,
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
                    height: 150,
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['product_name'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(5),
                          child: Text("1 " + data['measure']),
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.1),
                          ),
                        ),
                        Text(
                          "₹" + data['price'],
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Stock :" + data['stock'] + " " + data['measure'],
                          style: GoogleFonts.getFont(
                            "Lato",
                            fontSize: MediaQuery.of(context).size.width * 0.035,
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
                                child: Text(
                                  "Available Stock : " +
                                      data['stock'] +
                                      " " +
                                      data['measure'],
                                  style: GoogleFonts.getFont(
                                    "Lato",
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(20),
                                child: Wrap(
                                  children: <Widget>[
                                    TextField(
                                      controller: _textController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Quantity in ' +
                                            data['measure'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_textController.text.isEmpty) {
                                    return;
                                  }
                                  if (int.parse(_textController.text) <=
                                          int.parse(data['stock']) &&
                                      int.parse(_textController.text) > 0) {
                                    Map val = {
                                      "quantity": _textController.text,
                                      "request": false,
                                    };
                                    val.addAll(data);
                                    a.myProdBuy.add(val);
                                    Navigator.of(context).pop();
                                    FocusScope.of(context).unfocus();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Added to My List"),
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Add to My List"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Add"),
                ),
              ),
            const Divider(),
          ],
        ),
      ),
    ),
  );
}

Widget contact2(BuildContext context, dynamic data) {
  //mylist for seller
  SellerPost slr = Provider.of(context, listen: false);
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
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(10),
                  height: 140,
                  width: MediaQuery.of(context).size.width * 0.425,
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
                  height: 175,
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
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(5),
                        child: Text("1 " + data['measure']),
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.1),
                        ),
                      ),
                      Text(
                        "₹" + data['price'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Stock :" + data['stock'] + " " + data['measure'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.bold,
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductsAdd("Edit Product", data),
                      ),
                    );
                  },
                  child: const Text("Edit"),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await slr.deleteProduct(data);
                    slr.update();
                    slr.myPostSeller();
                  },
                  child: const Text("Remove"),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    ),
  );
}
