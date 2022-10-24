// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Future<List?> pick(context) async {
  return await showDialog(
    context: context,
    builder: (ctx) {
      return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2.4,
          width: MediaQuery.of(context).size.height / 2,
          child: Map(),
        ),
      );
    },
  );
}

class Map extends StatefulWidget {
  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late LatLng post = LatLng(9.925969054065545, 78.13394776520929);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      title: const Padding(
        padding: EdgeInsets.all(10),
        child: Text("Pick Location"),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 2.5,
        width: MediaQuery.of(context).size.height / 2,
        child: FlutterMap(
          options: MapOptions(
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            center: post,
            zoom: 14.0,
            onTap: (position, val) {
              setState(() {
                post.latitude = val.latitude;
                post.longitude = val.longitude;
              });
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  point: post,
                  builder: (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context, [post.latitude, post.longitude]);
          },
          child: const Text("Pick"),
        ),
      ],
    );
  }
}
