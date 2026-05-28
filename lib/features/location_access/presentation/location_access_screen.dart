import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../home/presentation/home_screen.dart';

const Color _primaryColor = Color(0xFF00695C);

class LocationAccessScreen extends StatelessWidget {
  const LocationAccessScreen({super.key});

  Future<void> _enableLocationAccess(BuildContext context) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showLocationServiceDialog(context);
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          _showLocationSettingsDialog(context);
        }
        return;
      }

      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location permission: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable GPS/Location services in device settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied Forever'),
        content: const Text(
          'Please enable location permission from app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isCompact ? 10 : 20),
              Row(
                children: [
                  Icon(Icons.local_hospital, color: _primaryColor, size: isCompact ? 24 : 30),
                  SizedBox(width: isCompact ? 8 : 10),
                  Text(
                    'WellQueue',
                    style: TextStyle(fontSize: isCompact ? 28 : 34, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 12 : 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isCompact ? 24 : 32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 28,
                        spreadRadius: -8,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: isCompact ? 138 : 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
                          color: const Color(0xFFEAF2F1),
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          size: isCompact ? 56 : 68,
                          color: Color(0xFF7AA7A0),
                        ),
                      ),
                      SizedBox(height: isCompact ? 18 : 26),
                      Text(
                        'Find Care Nearby',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isCompact ? 32 : 40,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                      Text(
                        'WellQueue uses your location to find clinics with the shortest wait times around you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isCompact ? 15 : 17, color: const Color(0xFF536872), height: 1.35),
                      ),
                      SizedBox(height: isCompact ? 20 : 28),
                      ElevatedButton(
                        onPressed: () => _enableLocationAccess(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          minimumSize: Size(double.infinity, isCompact ? 52 : 58),
                        ),
                        child: Text(
                          'Allow Location',
                          style: TextStyle(fontSize: isCompact ? 18 : 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 14),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: isCompact ? 12 : 14, horizontal: isCompact ? 8 : 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3F4),
                          borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, color: Color(0xFF536872)),
                            SizedBox(width: isCompact ? 8 : 10),
                            Text(
                              'YOUR DATA IS PRIVATE & SECURE',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF536872),
                                fontSize: isCompact ? 11 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
