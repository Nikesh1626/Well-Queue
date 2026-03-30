import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clinic.dart';
import '../constants/supabase_schema.dart';

class ClinicService extends ChangeNotifier {
  static final ClinicService _instance = ClinicService._internal();

  factory ClinicService() {
    return _instance;
  }

  ClinicService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  List<Clinic> _clinics = [];
  List<Clinic> _filteredClinics = [];
  Clinic? _selectedClinic;
  bool _isLoading = false;
  String? _error;

  List<Clinic> get clinics => _clinics;
  List<Clinic> get filteredClinics => _filteredClinics;
  Clinic? get selectedClinic => _selectedClinic;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all clinics from Supabase
  Future<void> fetchClinics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from(SupabaseSchema.clinicsTable)
          .select()
          .order(SupabaseSchema.clinicCreatedAt, ascending: false);

      _clinics = response.map((e) => Clinic.fromJson(e)).toList();
      _filteredClinics = _clinics;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching clinics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get clinic by ID
  Future<Clinic?> getClinicById(String clinicId) async {
    try {
      final response = await _supabase
          .from(SupabaseSchema.clinicsTable)
          .select()
          .eq(SupabaseSchema.clinicId, clinicId)
          .single();

      return Clinic.fromJson(response);
    } catch (e) {
      debugPrint('Error getting clinic: $e');
      return null;
    }
  }

  /// Search clinics by name or address
  void searchClinics(String query) {
    if (query.isEmpty) {
      _filteredClinics = _clinics;
    } else {
      _filteredClinics = _clinics
          .where((clinic) =>
              clinic.name.toLowerCase().contains(query.toLowerCase()) ||
              clinic.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Filter clinics by service
  void filterByService(String service) {
    _filteredClinics = _clinics
        .where((clinic) =>
            clinic.services.contains(service))
        .toList();
    notifyListeners();
  }

  /// Sort clinics by distance
  void sortByDistance(
    double userLat,
    double userLng,
  ) {
    for (var clinic in _filteredClinics) {
      clinic = clinic.copyWith(
        distance: _calculateDistance(userLat, userLng, clinic.latitude,
            clinic.longitude),
      );
    }

    _filteredClinics.sort((a, b) =>
        (a.distance ?? 999999).compareTo(b.distance ?? 999999));
    notifyListeners();
  }

  /// Sort clinics by rating
  void sortByRating() {
    _filteredClinics.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  /// Sort clinics by wait time
  void sortByWaitTime() {
    _filteredClinics
        .sort((a, b) => a.waitTimeMinutes.compareTo(b.waitTimeMinutes));
    notifyListeners();
  }

  /// Set selected clinic
  void selectClinic(Clinic clinic) {
    _selectedClinic = clinic;
    notifyListeners();
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRad(lat1)) *
            Math.cos(_toRad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c; // Distance in km
  }

  double _toRad(double deg) => deg * (Math.pi / 180.0);
}

// Math helper class
class Math {
  static const double pi = 3.14159265358979323846;

  static double sin(double x) => Function.apply(double.parse, [x.toString()]);
  static double cos(double x) =>
      (1 - (x * x) / 2 + (x * x * x * x) / 24 - (x * x * x * x * x * x) / 720);
  static double sqrt(double x) => x < 0 ? 0 : (x == 0 ? 0 : _sqrt(x, x / 2));
  static double atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + pi;
    if (x < 0 && y < 0) return _atan(y / x) - pi;
    if (x == 0 && y > 0) return pi / 2;
    if (x == 0 && y < 0) return -pi / 2;
    return 0;
  }

  static double _sqrt(double x, double guess) {
    if ((guess * guess - x).abs() < 0.00001) return guess;
    return _sqrt(x, (guess + x / guess) / 2);
  }

  static double _atan(double x) {
    if (x.abs() > 1) return (x > 0 ? pi / 2 : -pi / 2) - _atan(1 / x);
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}
