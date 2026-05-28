import 'dart:async';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/models/clinic.dart';
import '../../myqueue/presentation/check_in_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../core/theme/app_theme.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      // Greeting header with notification button
      appBar: AppBar(
        title: Builder(builder: (context) {
          final auth = context.watch<AuthService>();
          final displayName = auth.currentUser?.firstName.isNotEmpty == true
              ? auth.currentUser!.firstName
              : (auth.currentUser?.fullName.isNotEmpty == true
                  ? auth.currentUser!.fullName
                : (auth.currentUser?.email.split('@').first ?? 'User'));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good day',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: theme.textTheme.headlineMedium?.copyWith(color: AppTheme.primaryDark),
              ),
            ],
          );
        }),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                // TODO: navigate to notifications screen
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ],
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
  static const List<String> _filters = [
    'Open now',
    '< 15 min',
    'Closest',
    'Top rated',
  ];

  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _isLoadingClinics = true;
  bool _isMapExpanded = false;
  int _selectedFilterIndex = 0;
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
          _isLoadingClinics = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isLoadingClinics = false;
          _nearbyClinics = [];
        });
      },
    );
  }

    void _toggleMapSize() {
      setState(() {
        _isMapExpanded = !_isMapExpanded;
      });
    }

    void _recenterMap() {
      if (_currentLocation == null) return;
      _mapController.move(_currentLocation!, 13.0);
    }

    Widget _buildFilterChips() {
      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final selected = _selectedFilterIndex == index;
            return ChoiceChip(
              label: Text(_filters[index]),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF4E666E),
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.surfaceSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              showCheckmark: false,
            );
          },
        ),
      );
    }

  @override
  void dispose() {
    _clinicSubscription?.cancel();
    super.dispose();
  }

  List<Clinic> _applyFilter(List<Clinic> clinics) {
    final filtered = List<Clinic>.from(clinics);

    switch (_selectedFilterIndex) {
      case 0:
        return filtered.where((clinic) => clinic.waitTimeMinutes > 0).toList();
      case 1:
        return filtered.where((clinic) => clinic.waitTimeMinutes <= 15).toList();
      case 2:
        filtered.sort(
          (a, b) => (a.distance ?? double.infinity)
              .compareTo(b.distance ?? double.infinity),
        );
        return filtered;
      case 3:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        return filtered;
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClinics = _applyFilter(_nearbyClinics);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 390;
    final fastestWait = filteredClinics.isEmpty
        ? 0
        : filteredClinics
            .map((c) => c.waitTimeMinutes)
            .reduce((a, b) => a < b ? a : b);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isCompact ? 12 : 16, 8, isCompact ? 12 : 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF1B8D87)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.26),
                  blurRadius: 28,
                  spreadRadius: -12,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queue Snapshot',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '${filteredClinics.length} clinics live nearby',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 21 : 24,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _metricPill(Icons.timer_outlined, fastestWait > 0 ? '$fastestWait min fastest' : 'No active wait data'),
                    const SizedBox(width: 10),
                    _metricPill(Icons.local_hospital_outlined, '${filteredClinics.length} options'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const CustomSearchBar(),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            height: _isMapExpanded ? (isCompact ? 380 : 420) : (isCompact ? 280 : 320),
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _isLoadingLocation
                        ? const Center(child: CircularProgressIndicator())
                        : _currentLocation == null
                            ? const Center(child: Text('Unable to load map'))
                            : FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _currentLocation!,
                                  initialZoom: 13.0,
                                  minZoom: 5,
                                  maxZoom: 18,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                      ...filteredClinics.take(3).map(
                                            (clinic) => Marker(
                                              point: LatLng(
                                                clinic.latitude,
                                                clinic.longitude,
                                              ),
                                              width: 38,
                                              height: 38,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF00695C),
                                                  borderRadius: BorderRadius.circular(19),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2.5,
                                                  ),
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
                  Positioned(
                    left: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: _toggleMapSize,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isMapExpanded
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              size: 16,
                              color: const Color(0xFF00695C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isMapExpanded ? 'Collapse' : 'Expand',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00695C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: _recenterMap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Color(0xFF00695C),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (filteredClinics.isNotEmpty)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: filteredClinics.take(2).map((clinic) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clinic.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: isCompact ? 12 : 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${clinic.waitTimeMinutes} min wait',
                                      style: TextStyle(
                                        color: Color(0xFF00695C),
                                        fontWeight: FontWeight.w600,
                                        fontSize: isCompact ? 11 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinics nearby',
                    style: TextStyle(fontSize: isCompact ? 21 : 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sorted by your selected filter',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: isCompact ? 12 : 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: navigate to full clinics list
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          NearbyClinicsList(
            clinics: filteredClinics,
            isLoading: _isLoadingClinics,
          ),
        ],
      ),
    );
  }

  Widget _metricPill(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
