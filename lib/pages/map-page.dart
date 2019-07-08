import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final Map<MarkerId, Marker> markers;
  final LatLng cameraPosition;
  final bool isCenterMap;
  final Function() onChanged;

  MapPage({Key key, @required this.markers, @required this.cameraPosition, @required this.isCenterMap, @required this.onChanged}) : super(key: key);

  static MapPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<MapPageState>());

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {

  Completer<GoogleMapController> _controller = Completer();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (_controller.isCompleted && widget.isCenterMap == true) {
      _controller.future.then((mapController) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: widget.cameraPosition, zoom: 9.0)));
        widget.onChanged();
      });

    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.cameraPosition,
        zoom: 11.0,
      ),
      markers: Set<Marker>.of(widget.markers.values),
    );

  }

  void _onMapCreated(GoogleMapController controller){

    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }
}
