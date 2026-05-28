import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {

  final Location _locationController = Location();

  static const LatLng _pGooglePlex = LatLng(-37.71112804668473, 144.5917238006204);
  static const LatLng _pApplePark = LatLng(-37.82200579563919, 145.1772987824447); // 23 east india avanue
  LatLng? _currentP;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }
@override                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
  Widget build(BuildContext context) {
return Scaffold(
  body:_currentP == null ? const Center(child: Text("Loading..")
    ) : GoogleMap(initialCameraPosition: CameraPosition(
    target:  _pGooglePlex,
    zoom: 9
    ),
    markers: {
      Marker(
        markerId: MarkerId('_currentLocation'),
        icon: BitmapDescriptor.defaultMarker,
        position: _pGooglePlex,
        infoWindow: const InfoWindow(
          title: 'Google Plex Park',
          snippet: 'A very beautiful place',
        ),
      ),
      Marker(
        markerId: MarkerId('_sourceLocation'),
        icon: BitmapDescriptor.defaultMarker,
        position: _pApplePark,
        infoWindow: const InfoWindow(
          title: 'Apple Park',
          snippet: 'A very beautiful place',
        ),
      ),
    },
    ),
  ); 
  }
  Future<void> getLocationUpdates() async{
    bool serviceEnabled;

    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();

    if (!serviceEnabled){
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled){
        permissionGranted = await _locationController.requestPermission();
      }
      else {
        return;
      }
    }
    permissionGranted = await _locationController.hasPermission();

    if (permissionGranted == PermissionStatus.denied){
      permissionGranted = await _locationController.requestPermission();
      if(permissionGranted != PermissionStatus.granted)
      {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation){
      if(currentLocation.latitude != null && currentLocation.longitude != null){
        setState(() { 
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }
} 