// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class WebScrap extends StatefulWidget {
  String name, type;
  WebScrap(this.name, this.type);
  @override
  State<WebScrap> createState() => _WebScrapState();
}

class _WebScrapState extends State<WebScrap> {
  List image = [];

  @override
  void initState() {
    super.initState();
    image.clear();
  }

  Future getWebsiteData() async {
    final url = "https://www.flipkart.com/search?q=" +
        widget.name +
        "%20" +
        widget.type;
    final response = await http.get(Uri.parse(url));
    dom.Document html = dom.Document.html(response.body);
    image = html
        .querySelectorAll('div > div > img')
        .map((e) {
          var a = e.attributes['src'].toString();
          if (!a.startsWith("static-assets-web") &&
              !a.startsWith("//static-assets-web")) {
            return a;
          }
        })
        .toList()
        .sublist(0, 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getWebsiteData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: image.length,
              itemBuilder: ((context, index) {
                try {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    child: GestureDetector(
                      child: Image.network(
                        image[index],
                        errorBuilder: (context, error, stackTrace) =>
                            const CircularProgressIndicator(),
                      ),
                      onTap: () {
                        Navigator.pop(context, image[index]);
                      },
                    ),
                  );
                } catch (e) {
                  return const SizedBox();
                }
              }),
            );
          }
          return SafeArea(
            child: Builder(
              builder: ((context) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fetching Images...' + widget.name),
                      const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
