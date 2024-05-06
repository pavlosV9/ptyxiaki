import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ptyxiaki/clas/Item.dart'; // Make sure this path is correct
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  ItemBrain? itemBrain;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _updateMarkers());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    itemBrain = Provider.of<ItemBrain>(context);
    itemBrain?.addListener(_updateMarkers);
  }

  @override
  void dispose() {
    itemBrain?.removeListener(_updateMarkers);
    super.dispose();
  }

  void _updateMarkers() {
    if (!mounted) return;

    final items = Provider.of<ItemBrain>(context, listen: false).getList();
    final newMarkers = items
        .where((item) => item.lat != null && item.long != null)
        .map((item) => Marker(
      markerId: MarkerId(item.id ?? Uuid().v4()),
      position: LatLng(item.lat!, item.long!),
      infoWindow: InfoWindow(title: item.type, snippet: item.dateTime?.toIso8601String()),
    ))
        .toSet();
    if (!setEquals(newMarkers, _markers)) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  final Uri _url = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSd5KnB44VpPzuDF21MyDOIZ_ewcWQvcTfq7nGotIGdDhgNJcg/viewform?usp=sf_link');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Of Obstacles"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(35.1264, 33.4299), // Center of Cyprus
                zoom: 8.5,
              ),
              markers: _markers,
              mapType: MapType.normal,
            ),
          ),
          ElevatedButton(
            onPressed: _launchUrl,
            child: Text('Answer The Questions'),
          )
        ],
      ),
    );
  }
}
