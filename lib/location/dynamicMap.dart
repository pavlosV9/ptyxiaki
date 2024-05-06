import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ptyxiaki/clas/Item.dart';
class MapSample extends StatefulWidget {
  final double? lat;
  final double? long;
  const MapSample(this.lat, this.long, {Key? key}) : super(key: key); // Ensure you pass the key to the super constructor if needed.

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  @override
  Widget build(BuildContext context) {
    // Check if both lat and long are not null
    if (widget.lat != null && widget.long != null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height/2, // Specify the height of the map
        width: MediaQuery.of(context).size.width, // Use full width of the context
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat!, widget.long!), // Use lat and long from the widget
            zoom: 16.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('marker_1'), // A unique id for this marker
              position: LatLng(widget.lat!, widget.long!), // Marker position on the map
            ),
          },
        ),
      );
    } else {
      // Return an alternative widget if lat or long is null
      return Center(
        child: Text('Location data not available.'),
      );
    }
  }
}
