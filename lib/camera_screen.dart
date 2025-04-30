import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/sphere_style.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late FlutterEarthGlobeController _controller;
  final double markerSize = 0.2;

  final List<GlobeMarker> markers = [
    GlobeMarker(
      latitude: 40.7128,
      longitude: -74.0060,
      widget: const MarkerWidget(city: 'New York'),
    ),
    GlobeMarker(
      latitude: 51.5074,
      longitude: -0.1278,
      widget: const MarkerWidget(city: 'London'),
    ),
    GlobeMarker(
      latitude: 35.6762,
      longitude: 139.6503,
      widget: const MarkerWidget(city: 'Tokyo'),
    ),
    GlobeMarker(
      latitude: -33.8688,
      longitude: 151.2093,
      widget: const MarkerWidget(city: 'Sydney'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = FlutterEarthGlobeController(
      rotationSpeed: 0.1,
      isBackgroundFollowingSphereRotation: true,
      isZoomEnabled: true,
      zoom: 1.0,
      maxZoom: 1.6,
      minZoom: 0.5,
      // Adding sphere style for better visibility
      sphereStyle: SphereStyle(
        shadowColor: Colors.blue.withOpacity(0.5),
        shadowBlurStyle: BlurStyle.outer,
        shadowBlurSigma: 20,
        showShadow: true,
        showGradientOverlay: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Earth Globe')),
      body: Center(
        child: FlutterEarthGlobe(
          controller: _controller,
          radius: 150,

          // Pass the markers to make them visible
        ),
      ),
    );
  }
}

class GlobeMarker {
  final double latitude;
  final double longitude;
  final Widget widget;

  GlobeMarker({
    required this.latitude,
    required this.longitude,
    required this.widget,
  });
}

class MarkerWidget extends StatelessWidget {
  final String city;

  const MarkerWidget({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        city,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
