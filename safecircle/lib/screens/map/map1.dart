import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class NearbyPlace {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lon;
  final double distanceKm;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180.0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Map',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MapPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location location = Location();
  StreamSubscription<LocationData>? locationSub;

  double liveLat = 0.0;
  double liveLon = 0.0;
  bool locationReady = false;
  bool loadingPlaces = false;

  Map<String, List<NearbyPlace>> byType = {
    'hospital': [],
    'police': [],
    'pharmacy': [],
    'fire_station': [],
  };

  String selectedType = 'hospital';
  NearbyPlace? selectedPlace;

  Timer? _placesTimer;
  double? _lastFetchLat;
  double? _lastFetchLon;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    locationSub?.cancel();
    _placesTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);

    final loc = await location.getLocation();
    setState(() {
      liveLat = loc.latitude ?? 0.0;
      liveLon = loc.longitude ?? 0.0;
      locationReady = true;
    });

    _fetchAllPlaces(); // initial fetch

    locationSub = location.onLocationChanged.listen((locData) {
      setState(() {
        liveLat = locData.latitude ?? 0.0;
        liveLon = locData.longitude ?? 0.0;
        locationReady = true;
      });
      _schedulePlacesFetch();
    });
  }

  void _schedulePlacesFetch() {
    // Only fetch if moved more than 0.5 km
    if (_lastFetchLat != null &&
        _lastFetchLon != null &&
        NearbyPlace._haversineKm(
              liveLat,
              liveLon,
              _lastFetchLat!,
              _lastFetchLon!,
            ) <
            0.5) {
      return;
    }

    _lastFetchLat = liveLat;
    _lastFetchLon = liveLon;

    _placesTimer?.cancel();
    _placesTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _fetchAllPlaces();
    });
  }

  Future<void> _fetchAllPlaces() async {
    setState(() => loadingPlaces = true);

    final types = ['hospital', 'police', 'pharmacy', 'fire_station'];
    for (final type in types) {
      byType[type] = await _fetchNearby(type);
    }

    setState(() => loadingPlaces = false);
  }

  Future<List<NearbyPlace>> _fetchNearby(String type) async {
    String query = '';

    switch (type) {
      case 'hospital':
      case 'police':
      case 'fire_station':
        query = 'node["amenity"="$type"](around:6000,$liveLat,$liveLon);';
        break;
      case 'pharmacy':
        // Fetch both amenity=pharmacy and shop=chemist
        query =
            'node["amenity"="Medical"](around:6000,$liveLat,$liveLon);'
            'node["shop"="chemist"](around:6000,$liveLat,$liveLon);';
        break;
      // You can add more types here if needed
    }

    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];$query out;',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) return [];

    final data = json.decode(res.body);
    final List elements = data['elements'] ?? [];

    return elements
        .map((e) {
          final double lat = e['lat'];
          final double lon = e['lon'];
          final name = e['tags']?['name'] ?? 'Unknown $type';
          return NearbyPlace(
            id: e['id'].toString(),
            name: name,
            type: type,
            lat: lat,
            lon: lon,
            distanceKm: NearbyPlace._haversineKm(liveLat, liveLon, lat, lon),
          );
        })
        .where((p) => p.distanceKm <= 6.0)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'pharmacy':
        return Icons.medication;
      case 'fire_station':
        return Icons.fire_truck;
      default:
        return Icons.place;
    }
  }

  Future<void> _openInMaps(NearbyPlace p) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lon}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!locationReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final places = byType[selectedType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location Map"),
        backgroundColor: const Color.fromARGB(255, 235, 139, 139),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(liveLat, liveLon),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(liveLat, liveLon),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 42,
                    ),
                  ),
                  ...places.map(
                    (p) => Marker(
                      point: LatLng(p.lat, p.lon),
                      width: 40,
                      height: 40,
                      child: InkWell(
                        onTap: () => _openInMaps(p),
                        child: Icon(
                          _iconForType(p.type),
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.12,
            maxChildSize: 0.6,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, -4),
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children:
                            ['hospital', 'police', 'pharmacy', 'fire_station']
                                .map(
                                  (type) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(type.toUpperCase()),
                                      selected: selectedType == type,
                                      onSelected: (_) =>
                                          setState(() => selectedType = type),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    Expanded(
                      child: controller.hasClients
                          ? _buildPlaceList(controller, places)
                          : _buildPlaceList(ScrollController(), places),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceList(
    ScrollController controller,
    List<NearbyPlace> places,
  ) {
    if (loadingPlaces) return const Center(child: CircularProgressIndicator());
    if (places.isEmpty)
      return const Center(child: Text("No nearby places within 6 km"));

    return ListView.builder(
      controller: controller,
      itemCount: places.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final p = places[index];
        final isActive = selectedPlace?.id == p.id;
        return Card(
          elevation: isActive ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(_iconForType(p.type), color: Colors.black),
            title: Text(p.name),
            subtitle: Text("${p.distanceKm.toStringAsFixed(2)} km away"),
            trailing: isActive
                ? TextButton(
                    onPressed: () => _openInMaps(p),
                    child: const Text("Navigate"),
                  )
                : null,
            onTap: () => setState(() => selectedPlace = p),
          ),
        );
      },
    );
  }
}
