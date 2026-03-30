import 'dart:async';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/clinic.dart';
import '../../myqueue/presentation/check_in_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/clinic_repository.dart';
import 'widgets/custom_search_bar.dart';
import 'widgets/nearby_clinics_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getCurrentWidget() {
    switch (_selectedIndex) {
      case 0:
        return const _HomeContent();
      case 1:
        return const CheckInScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const _HomeContent();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.spa_rounded, color: Color(0xFF00695C)),
            SizedBox(width: 8),
            Text('WellQueue', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
      ),
      body: _getCurrentWidget(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00695C),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_bottom_rounded), label: 'My Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  final ClinicRepository _clinicRepository = ClinicRepository();
  StreamSubscription<List<Clinic>>? _clinicSubscription;
  List<Clinic> _nearbyClinics = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _subscribeNearbyClinics();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingLocation = false;
        _currentLocation = const LatLng(28.6139, 77.2090);
      });
    }
  }

  void _subscribeNearbyClinics() {
    _clinicSubscription = _clinicRepository.streamNearbyClinics().listen(
      (clinics) {
        if (!mounted) return;
        setState(() {
          _nearbyClinics = clinics;
        });
      },
    );
  }

  @override
  void dispose() {
    _clinicSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSearchBar(),
          const SizedBox(height: 16),
          Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 26,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : _currentLocation == null
                      ? const Center(child: Text('Unable to load map'))
                      : FlutterMap(
                          options: MapOptions(
                            initialCenter: _currentLocation!,
                            initialZoom: 13.0,
                            minZoom: 5,
                            maxZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.well_queue_2026',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFBC1F1F),
                                    size: 40,
                                  ),
                                ),
                                ..._nearbyClinics.map(
                                  (clinic) => Marker(
                                    point: LatLng(clinic.latitude, clinic.longitude),
                                    width: 38,
                                    height: 38,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00695C),
                                        borderRadius: BorderRadius.circular(19),
                                        border: Border.all(color: Colors.white, width: 2.5),
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital,
                                        color: Colors.white,
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Clinics nearby', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
              Text('View all', style: TextStyle(fontSize: 18, color: Color(0xFF00695C), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          const NearbyClinicsList(),
        ],
      ),
    );
  }
}
