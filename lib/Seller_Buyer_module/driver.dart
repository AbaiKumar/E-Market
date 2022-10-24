// ignore_for_file: use_key_in_widget_constructors, must_be_immutable
import 'package:flutter/material.dart';
import 'package:market/Seller_Buyer_module/elaborate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market/common_widget/drawer.dart';
import 'package:market/common_widget/bottomnavbar.dart';
import 'package:market/model/sellerpost.dart';

class Driver extends StatefulWidget {
  @override
  State<Driver> createState() => _CommonHomeState();
}

class _CommonHomeState extends State<Driver> {
  late TextEditingController _txtcontroller;
  late Map<String, Function> wid;
  late SellerPost a;

  @override
  void initState() {
    super.initState();
    _txtcontroller = TextEditingController();
    Future.delayed(Duration.zero, () {});
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'E-',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Market',
                    style: TextStyle(fontWeight: FontWeight.normal),
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
                            hintText: "search by source place",
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
          DriverHome(false, changer, searchVal),
          DriverHome(true, changer, searchVal),
          Container(),
        ][index],
      ),
    );
  }
}

class DriverHome extends StatefulWidget {
  bool switcher;
  bool filter;
  String search;
  DriverHome(this.switcher, this.filter, this.search);
  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  List data = [];
  List myjob = [];
  late List filter;
  late SellerPost sp;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      data = await sp.getAllJob();
      myjob = await sp.getDriverIndiJob();
      setState(() {});
    });
  }

  Widget con(data) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Elaborate(data, false)));
      },
      child: Container(
          margin: const EdgeInsets.all(10),
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
                    borderRadius:
                        BorderRadius.circular(10.0), //add border radius
                    child: Image.network(
                      data['imageURL'],
                      fit: BoxFit.fill,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Name : " + data['product_name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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
                      Text(
                        "Destination Address : " + data['dest'],
                        style: GoogleFonts.getFont(
                          "Lato",
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (!widget.switcher)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await sp.myPostDriver(data);
                              await refresh();
                              setState(() {});
                            },
                            label: const Text("Take Job"),
                            icon: const Icon(Icons.work_outline),
                          ),
                        ),
                      if (widget.switcher)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          color: Colors.green,
                          alignment: Alignment.center,
                          child: data['confirm']
                              ? const Text("Confirmed")
                              : const Text("In progress"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future refresh() async {
    data = await sp.getAllJob();
    myjob = await sp.getDriverIndiJob();
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
    return;
  }

  void valueUpdate() async {
    filter = [];
    if (widget.search.isEmpty) {
      filter = sp.sellerList;
      return;
    }
    for (var i in data) {
      if (widget.search.isEmpty) {
        filter = data;
        return;
      }
      if (i['splace']
          .toString()
          .toLowerCase()
          .contains(widget.search.toLowerCase())) {
        filter.add(i);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    sp = Provider.of(context);
    valueUpdate();
    return !widget.filter
        ? RefreshIndicator(
            onRefresh: refresh,
            child: !widget.switcher
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      return data.isEmpty ? const Text('hi') : con(data[index]);
                    },
                    shrinkWrap: true,
                    itemCount: data.length)
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return myjob.isEmpty
                          ? const Text('hi')
                          : con(myjob[index]);
                    },
                    shrinkWrap: true,
                    itemCount: myjob.length))
        : ListView.builder(
            itemBuilder: (context, index) {
              return con(filter[index]);
            },
            shrinkWrap: true,
            itemCount: filter.length);
  }
}
