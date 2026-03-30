import 'package:flutter/material.dart';
import '../../data/clinic_repository.dart';
import '../../../../core/models/clinic.dart';
import 'clinic_card.dart';

class NearbyClinicsList extends StatefulWidget {
  const NearbyClinicsList({super.key});

  @override
  State<NearbyClinicsList> createState() => _NearbyClinicsListState();
}

class _NearbyClinicsListState extends State<NearbyClinicsList> {
  final ClinicRepository _repository = ClinicRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Clinic>>(
      stream: _repository.streamNearbyClinics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Unable to load clinics: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No clinics found nearby.')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final clinic = snapshot.data![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClinicCard(clinic: clinic),
            );
          },
        );
      },
    );
  }
}
