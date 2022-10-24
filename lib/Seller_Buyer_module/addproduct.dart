// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:market/common_widget/commonfunctions.dart';
import 'package:market/model/sellerpost.dart';
import 'package:market/common_widget/webscrap.dart';
import 'package:provider/provider.dart';

class ProductsAdd extends StatefulWidget {
  String txt;
  Map data;
  ProductsAdd(this.txt, this.data);
  @override
  State<ProductsAdd> createState() => _ProductsAddState();
}

class _ProductsAddState extends State<ProductsAdd> {
  final _url = FocusNode();
  final _price = FocusNode();
  final _type = FocusNode();
  final _quantity = FocusNode();
  final _measure = FocusNode();
  final _glob = GlobalKey<FormState>();
  late String name = "",
      type = "fruit",
      price = "",
      url = "",
      quantity = "",
      measure = "Kg";
  late final FirebaseMessaging message;
  @override
  void initState() {
    super.initState();
    message = FirebaseMessaging.instance;
    if (widget.data.isEmpty) {
      return;
    }
    var m = widget.data;
    name = m['product_name'];
    type = m['type'];
    quantity = m['stock'];
    price = m['price'];
    measure = m['measure'];
    url = m['imageURL'];
  }

  @override
  void dispose() {
    _url.dispose();
    _price.dispose();
    _type.dispose();
    _measure.dispose();
    _quantity.dispose();
    super.dispose();
  }

  void upload(BuildContext c, SellerPost a) async {
    bool val = _glob.currentState!.validate();
    if (!val || url.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pick Image")));
      return;
    }
    _glob.currentState?.save();
    var res;
    if (widget.data.isEmpty) {
      res = await a.addProduct(name, price, type, url, quantity, measure);
    } else {
      res = await a.updateProduct(
          widget.data['id'], name, price, type, url, quantity, measure);
    }

    if (res) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data added.")));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data not added.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    SellerPost a = Provider.of(context, listen: false);
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.txt),
          actions: [
            IconButton(
              onPressed: () => upload(context, a),
              icon: const Icon(
                Icons.save,
              ),
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
              key: _glob,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Name",
                    ),
                    initialValue: name,
                    onChanged: (_) {
                      name = _.toString();
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_quantity);
                    },
                    onSaved: (_) {
                      name = _.toString();
                    },
                    validator: (str) {
                      if (str == null || str.isEmpty) {
                        return "Please mention name ";
                      } else if (str.length > 20) {
                        return "Enter name below 20 characters";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Stock",
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_measure);
                    },
                    onSaved: (str) {
                      quantity = str.toString();
                    },
                    initialValue: quantity,
                    validator: (str) {
                      if (str == null ||
                          str.isEmpty ||
                          double.parse(str) <= 0) {
                        return "Mention Quantity ";
                      }
                      return null;
                    },
                    focusNode: _quantity,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    child: DropdownButtonFormField(
                      value: measure,
                      itemHeight: 50,
                      items: const [
                        DropdownMenuItem(
                          alignment: Alignment.center,
                          child: Text("Kg"),
                          value: "Kg",
                        ),
                        DropdownMenuItem(
                          alignment: Alignment.center,
                          child: Text("Piece"),
                          value: "Piece",
                        )
                      ],
                      onChanged: (_) {
                        measure = _.toString();
                        FocusScope.of(context).requestFocus(_price);
                      },
                      onSaved: (str) {
                        measure = str.toString();
                      },
                      validator: (str) {
                        if (str == null || str.toString().isEmpty) {
                          return "Select a quantity measurement";
                        }
                        return null;
                      },
                      focusNode: _measure,
                      hint: const Text("Measurement"),
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Price 1 kg/1 piece",
                    ),
                    initialValue: price,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_type);
                    },
                    onSaved: (str) {
                      price = str.toString();
                    },
                    validator: (str) {
                      if (str == null ||
                          str.isEmpty ||
                          double.parse(str) <= 0) {
                        return "Mention price ";
                      }
                      return null;
                    },
                    focusNode: _price,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    child: DropdownButtonFormField(
                      value: type,
                      itemHeight: 50,
                      items: const [
                        DropdownMenuItem(
                          alignment: Alignment.center,
                          child: Text("fruit"),
                          value: "fruit",
                        ),
                        DropdownMenuItem(
                          alignment: Alignment.center,
                          child: Text("vegetable"),
                          value: "vegetable",
                        )
                      ],
                      onChanged: (_) {
                        type = _.toString();
                        FocusScope.of(context).requestFocus(_url);
                      },
                      onSaved: (str) {
                        type = str.toString();
                      },
                      validator: (str) {
                        if (str == null || str.toString().isEmpty) {
                          return "Select a type";
                        }
                        return null;
                      },
                      focusNode: _type,
                      hint: const Text("Type"),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        child: const Text("Pick Image"),
                        onPressed: () async {
                          if (name.isNotEmpty && type.isNotEmpty) {
                            url = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => WebScrap(name, type)),
                              ),
                            );
                          }
                        },
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              _glob.currentState?.reset();
                            },
                            icon: const Icon(Icons.clear, color: Colors.red),
                            label: const Text('Clear'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              upload(context, a);
                            },
                            icon: Icon(Icons.done_outlined,
                                color: Colors.green[800]),
                            label: widget.data.isEmpty
                                ? const Text('Submit')
                                : const Text('Update'),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
