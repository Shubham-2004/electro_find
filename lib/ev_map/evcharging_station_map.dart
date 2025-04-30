import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class EVChargingStationMap extends StatefulWidget {
  @override
  _EVChargingStationMapState createState() => _EVChargingStationMapState();
}

class _EVChargingStationMapState extends State<EVChargingStationMap> {
  LatLng? currentLocation;
  List<ChargingStation> chargingStations = [];
  bool isLoading = true;
  final String apiKey = '98aec744-8a8a-42bf-9f2c-c3b1f1c0aaa6';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Fetch charging stations once we have location
    await _fetchChargingStations();
  }

  Future<void> _fetchChargingStations() async {
    if (currentLocation == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Use a more accurate URL with lat/long proximity parameters
      final String apiUrl =
          'https://api.openchargemap.io/v3/poi/?output=json'
          '&countrycode=IN'
          '&maxresults=750'
          '&compact=true'
          '&verbose=false'
          '&latitude=${currentLocation!.latitude}'
          '&longitude=${currentLocation!.longitude}'
          '&distance=10000'
          '&distanceunit=KM'
          '&key=$apiKey';

      // Add a small delay to prevent hitting rate limits
      await Future.delayed(Duration(milliseconds: 500));

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent':
              'EVChargingStationFinder/1.0 (Flutter; Contact: example@email.com)',
          'Accept': 'application/json',
          'X-API-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Successfully received ${data.length} charging stations');

        if (data.isEmpty) {
          setState(() {
            chargingStations = [];
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No charging stations found within 50km of your location',
              ),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        try {
          List<ChargingStation> stations = [];

          for (var stationData in data) {
            try {
              final station = ChargingStation.fromJson(stationData);
              // Only add stations with valid coordinates
              if (station.latitude != 0 && station.longitude != 0) {
                stations.add(station);
              }
            } catch (e) {
              print('Error parsing station: $e');
              // Continue with next station if one fails
            }
          }

          setState(() {
            chargingStations = stations;
            isLoading = false;
          });

          if (chargingStations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No valid charging stations found in this area'),
                duration: Duration(seconds: 5),
              ),
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing station data: $e'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });

        String errorMessage = 'API Error (${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          if (errorData['description'] != null) {
            errorMessage = errorData['description'];
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error accessing charging station data: $errorMessage',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EV Charging Stations in India',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showAttributionDialog(),
            tooltip: 'Attribution',
          ),
        ],
      ),
      body:
          currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 10,
                      minZoom: 5,
                      maxZoom: 19,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.evcharging_station_map',
                        maxZoom: 19,
                      ),
                      CurrentLocationLayer(
                        style: LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            child: Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          markerSize: Size(40, 40),
                          markerDirection: MarkerDirection.heading,
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          for (var station in chargingStations)
                            Marker(
                              width: 60,
                              height: 60,
                              point: LatLng(
                                station.latitude,
                                station.longitude,
                              ),
                              child: GestureDetector(
                                onTap: () => _showStationDetails(station),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.ev_station,
                                        color:
                                            station.isOperational
                                                ? Colors.red
                                                : Colors.green,
                                        size: 30,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                      ),
                                      child: Text(
                                        station.name.length > 12
                                            ? '${station.name.substring(0, 10)}...'
                                            : station.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Location: ${currentLocation!.latitude.toStringAsFixed(5)}, ${currentLocation!.longitude.toStringAsFixed(5)}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Charging Stations: ${chargingStations.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading charging stations in India...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.green.shade700,
                      onPressed: _fetchChargingStations,
                      child: Icon(Icons.refresh),
                      tooltip: 'Refresh stations',
                    ),
                  ),
                ],
              ),
    );
  }

  void _showAttributionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Data Attribution'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Charging station data provided by:'),
                SizedBox(height: 8),
                Text(
                  'Open Charge Map Contributors',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 12),
                Text('Visit: https://openchargemap.org'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CLOSE'),
              ),
            ],
          ),
    );
  }

  void _showStationDetails(ChargingStation station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.8,
            minChildSize: 0.4,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  station.isOperational
                                      ? Colors.green
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              station.statusTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Address section
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Address: ${station.address}'),
                            Text('Town: ${station.town}'),
                            Text('State: ${station.stateOrProvince}'),
                            Text('Postal Code: ${station.postcode}'),
                            SizedBox(height: 4),
                            Text(
                              'Coordinates: ${station.latitude}, ${station.longitude}',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Operator info
                      if (station.operatorName != null &&
                          station.operatorName!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Operator Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Operator: ${station.operatorName}'),
                              if (station.operatorPhone != null)
                                Text('Contact: ${station.operatorPhone}'),
                              if (station.operatorEmail != null)
                                Text('Email: ${station.operatorEmail}'),
                            ],
                          ),
                        ),
                      SizedBox(height: 16),

                      // Connectors
                      if (station.connectors.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.electrical_services),
                                  SizedBox(width: 8),
                                  Text(
                                    'Connectors (${station.connectors.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...station.connectors.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    elevation: 0,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.connectionType,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (c.powerKW != null)
                                            Text('Power: ${c.powerKW} kW'),
                                          Text('Current: ${c.currentType}'),
                                          Text('Status: ${c.statusTitle}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 8),

                      // Usage information
                      Text(
                        'Usage Type: ${station.usageType}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Last Verified: ${station.dateLastVerified ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class ChargingStation {
  final int id;
  final String name;
  final String address;
  final String town;
  final String stateOrProvince;
  final String postcode;
  final double latitude;
  final double longitude;
  final String statusTitle;
  final bool isOperational;
  final String? operatorName;
  final String? operatorPhone;
  final String? operatorEmail;
  final String usageType;
  final String? dateLastVerified;
  final List<Connector> connectors;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.town,
    required this.stateOrProvince,
    required this.postcode,
    required this.latitude,
    required this.longitude,
    required this.statusTitle,
    required this.isOperational,
    this.operatorName,
    this.operatorPhone,
    this.operatorEmail,
    required this.usageType,
    this.dateLastVerified,
    required this.connectors,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    try {
      // Address info
      String address = '';
      String town = '';
      String stateOrProvince = '';
      String postcode = '';
      double latitude = 0.0;
      double longitude = 0.0;

      if (json['AddressInfo'] != null) {
        final addressInfo = json['AddressInfo'];
        address = addressInfo['AddressLine1'] ?? '';
        if (addressInfo['AddressLine2'] != null &&
            addressInfo['AddressLine2'].toString().isNotEmpty) {
          address += ", ${addressInfo['AddressLine2']}";
        }
        town = addressInfo['Town'] ?? '';
        stateOrProvince = addressInfo['StateOrProvince'] ?? '';
        postcode = addressInfo['Postcode'] ?? '';

        // Safely convert coordinates to double
        if (addressInfo['Latitude'] != null) {
          latitude = double.tryParse(addressInfo['Latitude'].toString()) ?? 0.0;
        }

        if (addressInfo['Longitude'] != null) {
          longitude =
              double.tryParse(addressInfo['Longitude'].toString()) ?? 0.0;
        }
      }

      // Operator info
      String? operatorName;
      String? operatorPhone;
      String? operatorEmail;

      if (json['OperatorInfo'] != null) {
        final operatorInfo = json['OperatorInfo'];
        operatorName = operatorInfo['Title'];
        operatorPhone = operatorInfo['PhonePrimaryContact'];
        operatorEmail = operatorInfo['ContactEmail'];
      }

      // Status info
      String statusTitle = 'Unknown';
      bool isOperational = false;

      if (json['StatusType'] != null) {
        statusTitle = json['StatusType']['Title'] ?? 'Unknown';
        isOperational = json['StatusType']['IsOperational'] ?? false;
      }

      // Usage type
      String usageType = 'Unknown';
      if (json['UsageType'] != null) {
        usageType = json['UsageType']['Title'] ?? 'Unknown';
      }

      // Date verified
      String? dateLastVerified;
      if (json['DateLastVerified'] != null) {
        dateLastVerified = json['DateLastVerified'].toString();
      }

      // Connectors - handle empty or malformed connector data
      List<Connector> connectors = [];
      if (json['Connections'] != null &&
          json['Connections'] is List &&
          (json['Connections'] as List).isNotEmpty) {
        for (var connector in json['Connections']) {
          try {
            connectors.add(Connector.fromJson(connector));
          } catch (e) {
            print('Error parsing connector: $e');
          }
        }
      }

      return ChargingStation(
        id: json['ID'] ?? 0,
        name: json['AddressInfo']?['Title'] ?? 'Unknown Station',
        address: address,
        town: town,
        stateOrProvince: stateOrProvince,
        postcode: postcode,
        latitude: latitude,
        longitude: longitude,
        statusTitle: statusTitle,
        isOperational: isOperational,
        operatorName: operatorName,
        operatorPhone: operatorPhone,
        operatorEmail: operatorEmail,
        usageType: usageType,
        dateLastVerified: dateLastVerified,
        connectors: connectors,
      );
    } catch (e) {
      print('Error in ChargingStation.fromJson: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }
}

class Connector {
  final String connectionType;
  final double? powerKW;
  final String currentType;
  final String statusTitle;

  Connector({
    required this.connectionType,
    this.powerKW,
    required this.currentType,
    required this.statusTitle,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    try {
      String connectionType = 'Unknown';
      if (json['ConnectionType'] != null) {
        connectionType = json['ConnectionType']['Title'] ?? 'Unknown';
      }

      String currentType = 'Unknown';
      if (json['CurrentType'] != null) {
        currentType = json['CurrentType']['Title'] ?? 'Unknown';
      }

      String statusTitle = 'Unknown';
      if (json['StatusType'] != null) {
        statusTitle = json['StatusType']['Title'] ?? 'Unknown';
      }

      double? powerKW;
      if (json['PowerKW'] != null) {
        powerKW = double.tryParse(json['PowerKW'].toString());
      }

      return Connector(
        connectionType: connectionType,
        powerKW: powerKW,
        currentType: currentType,
        statusTitle: statusTitle,
      );
    } catch (e) {
      print('Error in Connector.fromJson: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }
}
