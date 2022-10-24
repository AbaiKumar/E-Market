// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/review.dart';
import 'package:provider/provider.dart';
import 'package:market/Seller_Buyer_module/mylist.dart';
import 'package:market/common_widget/drawer.dart';
import 'package:market/Seller_Buyer_module/addproduct.dart';
import 'package:market/common_widget/bottomnavbar.dart';
import 'package:market/Seller_Buyer_module/home.dart';
import 'package:market/model/sellerpost.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonHome extends StatefulWidget {
  @override
  State<CommonHome> createState() => _CommonHomeState();
}

class _CommonHomeState extends State<CommonHome> {
  late TextEditingController _txtcontroller;
  late Map<String, Function> wid;
  late SellerPost a;

  @override
  void initState() {
    super.initState();
    _txtcontroller = TextEditingController();
    Future.delayed(Duration.zero, () {
      a.update();
      a.myPostSeller();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _txtcontroller.dispose();
  }

  var index = 0;
  var changer = false;
  String searchVal = "";
  void valchange(indx) {
    setState(() {
      index = indx;
    });
  }

  @override
  Widget build(BuildContext context) {
    a = Provider.of<SellerPost>(context);
    return Scaffold(
      bottomNavigationBar: BottomNav(valchange),
      drawer: CustomDrawer(),
      floatingActionButton: index == 0 && a.sellerType == "Seller"
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductsAdd("Add Products", {}),
                  ),
                );
              },
            )
          : null,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (a.sellerType != "Buyer") ...[
                      const Text(
                        'E-',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Market',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                    if (a.sellerType == "Buyer")
                      const Text(
                        'Happy to shop',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                pinned: true,
                floating: true,
                actions: [
                  IconButton(
                    padding: const EdgeInsets.only(right: 15),
                    onPressed: () {
                      Navigator.of(context).pushNamed("account");
                    },
                    icon: const Icon(Icons.account_circle_outlined),
                  ),
                ],
                bottom: index == 0
                    ? PreferredSize(
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
                            onTap: () {
                              setState(() {
                                changer = true;
                              });
                            },
                            textInputAction: TextInputAction.previous,
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: "Search products",
                              prefixIcon: Icon(Icons.search_outlined),
                            ),
                            onChanged: (_) {
                              setState(() {
                                searchVal = _;
                              });
                            },
                            onEditingComplete: () {
                              setState(() {
                                changer = false;
                                _txtcontroller.text = "";
                              });
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        preferredSize: const Size(double.infinity, 70))
                    : null,
              ),
            ];
          },
          body: [
            Home(changer, searchVal),
            MyList(),
            HireTransport(),
          ][index]),
    );
  }
}

class HireTransport extends StatefulWidget {
  @override
  State<HireTransport> createState() => _HireTransportState();
}

class _HireTransportState extends State<HireTransport> {
  List driver = [];
  late SellerPost val;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, changer);
  }

  Future changer() async {
    driver = await val.getIndiJob();
    setState(() {});
  }

  Widget con(data) {
    return Container(
        margin: const EdgeInsets.all(15),
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0), //add border radius
                  child: Image.network(
                    data['imageURL'],
                    fit: BoxFit.fill,
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Name : " + data['product_name'],
                      style: GoogleFonts.getFont(
                        "Lato",
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      "Quantity : " + data['quantity'] + data['measure'],
                      style: GoogleFonts.getFont(
                        "Lato",
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text(
                      "Source Address : " + data['src'],
                      style: GoogleFonts.getFont(
                        "Lato",
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                    Text("Destination Address : " + data['dest']),
                  ],
                ),
              ),
              if (!data['confirm'])
                Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Text("In Progress"),
                ),
              if (data['confirm'])
                Container(
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await showModalBottomSheet<void>(
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: SingleChildScrollView(
                              child: StarRating(data),
                            ),
                          );
                        },
                      );
                      await val.delAfterDelivery(data);
                      changer();
                    },
                    child: const Text("Delivered"),
                  ),
                )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    val = Provider.of(context, listen: false);
    return driver.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: driver.length,
            itemBuilder: (context, index) => con(driver[index]))
        : const Text('');
  }
}
